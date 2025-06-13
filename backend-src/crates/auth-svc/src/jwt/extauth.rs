use crate::jwt::{AuthState, VerificationResult};
use envoy_types::ext_authz::v3::pb::{Authorization, CheckRequest, CheckResponse};
use envoy_types::ext_authz::v3::{CheckRequestExt, CheckResponseExt};
use std::collections::HashMap;
use std::sync::Arc;
use tonic::{Code, Request, Response, Status};

#[derive(Debug)]
enum AuthScheme {
    Bearer(String),
    Basic(String),
}

pub(crate) struct AuthSvc {
    state: Arc<AuthState>,
}

impl AuthSvc {
    pub(crate) fn new(state: Arc<AuthState>) -> Self {
        Self { state }
    }
}

#[tonic::async_trait]
impl Authorization for AuthSvc {
    async fn check(
        &self,
        request: Request<CheckRequest>,
    ) -> Result<Response<CheckResponse>, Status> {
        let request = request.into_inner();
        let headers = request
            .get_client_headers()
            .ok_or_else(|| Status::invalid_argument("client headers not populated by envoy"))?;

        let auth_scheme = match parse_authorization_header(&headers) {
            Some(scheme) => scheme,
            None => {
                tracing::debug!("No valid authorization header found");
                return Ok(Response::new(CheckResponse::default()));
            }
        };

        match auth_scheme {
            AuthScheme::Bearer(jwt_token) => {
                match &self.state.verify_jwt(&jwt_token) {
                    VerificationResult::Valid {
                        role: _role,
                        username: _username,
                    } => Ok(Response::new(CheckResponse::with_status(Status::new(
                        Code::Ok,
                        "authorized",
                    )))),
                    VerificationResult::Expired => {
                        tracing::warn!("JWT token has expired");
                        Ok(Response::new(CheckResponse::with_status(Status::new(
                            Code::PermissionDenied,
                            "JWT token has expired",
                        ))))
                    }
                    VerificationResult::Invalid => {
                        // this is an error so we can see if there are sudden spikes in invalid tokens
                        tracing::error!("Invalid JWT token provided");
                        Ok(Response::new(CheckResponse::with_status(Status::new(
                            Code::PermissionDenied,
                            "invalid JWT token",
                        ))))
                    }
                }
            }
            AuthScheme::Basic(base64_credentials) => {
                // Handle Basic auth verification
                match &self.state.verify_basic_auth(&base64_credentials) {
                    Ok(_) => Ok(Response::new(CheckResponse::with_status(Status::new(
                        Code::Ok,
                        "authorized",
                    )))),
                    Err(_) => {
                        tracing::error!("Invalid basic auth credentials");
                        Ok(Response::new(CheckResponse::with_status(Status::new(
                            Code::PermissionDenied,
                            "invalid basic auth credentials",
                        ))))
                    }
                }
            }
        }
    }
}

fn parse_authorization_header(headers: &HashMap<String, String>) -> Option<AuthScheme> {
    if let Some(auth_header) = headers.get("Authorization").map(|h| h.as_str()) {
        if let Some(token) = auth_header.strip_prefix("Bearer ") {
            return Some(AuthScheme::Bearer(token.to_string()));
        }

        if let Some(credentials) = auth_header.strip_prefix("Basic ") {
            return Some(AuthScheme::Basic(credentials.to_string()));
        }
    }

    // Fallback to apikey header for JWT (common in Supabase)
    if let Some(api_key) = headers.get("apikey").map(|h| h.as_str()) {
        return Some(AuthScheme::Bearer(api_key.to_string()));
    }

    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::jwt::{AuthState, Claims};
    use base64::Engine;
    use base64::prelude::BASE64_STANDARD;
    use chrono::Utc;
    use envoy_types::ext_authz::v3::CheckResponseExt;
    use envoy_types::pb::envoy::service::auth::v3;
    use envoy_types::pb::envoy::service::auth::v3::attribute_context;
    use jsonwebtoken::{Algorithm, EncodingKey, Header, encode};
    use std::collections::HashMap;
    use tonic::{Code, Request};

    fn make_auth_state() -> Arc<AuthState> {
        let jwt_secret = BASE64_STANDARD.encode(b"secret");
        Arc::new(AuthState::new(jwt_secret, "admin".into(), "s3cr3t".into()))
    }

    fn create_jwt(role: &str, exp_offset: i64, secret: &[u8]) -> String {
        let now = Utc::now().timestamp();
        let claims = Claims {
            role: role.to_string(),
            iss: "f2".to_string(),
            iat: now,
            exp: now + exp_offset,
        };
        encode(
            &Header::new(Algorithm::HS256),
            &claims,
            &EncodingKey::from_secret(secret),
        )
        .unwrap()
    }

    #[test]
    fn test_parse_authorization_header() {
        // Test Bearer token
        let mut headers = HashMap::new();
        headers.insert("Authorization".into(), "Bearer token123".into());
        match parse_authorization_header(&headers) {
            Some(AuthScheme::Bearer(token)) => assert_eq!(token, "token123"),
            _ => panic!("Expected Bearer scheme"),
        }

        // Test Basic auth
        let mut headers = HashMap::new();
        headers.insert("Authorization".into(), "Basic credentials123".into());
        match parse_authorization_header(&headers) {
            Some(AuthScheme::Basic(creds)) => assert_eq!(creds, "credentials123"),
            _ => panic!("Expected Basic scheme"),
        }

        // Test apikey fallback
        let mut headers = HashMap::new();
        headers.insert("apikey".into(), "apikey123".into());
        match parse_authorization_header(&headers) {
            Some(AuthScheme::Bearer(token)) => assert_eq!(token, "apikey123"),
            _ => panic!("Expected Bearer scheme from apikey"),
        }

        // Test no auth header
        let headers = HashMap::new();
        assert!(parse_authorization_header(&headers).is_none());
    }

    #[tokio::test]
    async fn test_no_auth_header() {
        let svc = AuthSvc::new(make_auth_state());

        let req = CheckRequest {
            attributes: Some(v3::AttributeContext {
                source: None,
                destination: None,
                request: Some(attribute_context::Request {
                    time: None,
                    http: Some(attribute_context::HttpRequest {
                        id: "".to_string(),
                        method: "".to_string(),
                        headers: HashMap::new(),
                        header_map: None,
                        path: "".to_string(),
                        host: "".to_string(),
                        scheme: "".to_string(),
                        query: "".to_string(),
                        fragment: "".to_string(),
                        size: 0,
                        protocol: "".to_string(),
                        body: "".to_string(),
                        raw_body: vec![],
                    }),
                }),
                context_extensions: Default::default(),
                metadata_context: None,
                route_metadata_context: None,
                tls_session: None,
            }),
        };

        let resp = svc.check(Request::new(req)).await.unwrap();
        // Should return default response (neither deny nor allow explicitly)
        assert!(resp.get_ref().status.is_none());
    }

    #[tokio::test]
    async fn test_basic_auth_success() {
        let svc = AuthSvc::new(make_auth_state());
        let creds = BASE64_STANDARD.encode(b"admin:s3cr3t");
        let mut headers = HashMap::new();
        headers.insert("Authorization".into(), format!("Basic {}", creds));

        let req = CheckRequest {
            attributes: Some(v3::AttributeContext {
                source: None,
                destination: None,
                request: Some(attribute_context::Request {
                    time: None,
                    http: Some(attribute_context::HttpRequest {
                        id: "".to_string(),
                        method: "".to_string(),
                        headers: headers,
                        header_map: None,
                        path: "".to_string(),
                        host: "".to_string(),
                        scheme: "".to_string(),
                        query: "".to_string(),
                        fragment: "".to_string(),
                        size: 0,
                        protocol: "".to_string(),
                        body: "".to_string(),
                        raw_body: vec![],
                    }),
                }),
                context_extensions: Default::default(),
                metadata_context: None,
                route_metadata_context: None,
                tls_session: None,
            }),
        };

        let resp = svc.check(Request::new(req)).await.unwrap();
        let status = resp.get_ref().status.as_ref().unwrap();
        assert_eq!(status.code, Code::Ok as i32);
        assert_eq!(status.message, "authorized");
    }

    #[tokio::test]
    async fn test_basic_auth_failure() {
        let svc = AuthSvc::new(make_auth_state());
        let bad = BASE64_STANDARD.encode(b"admin:wrong");
        let mut headers = HashMap::new();
        headers.insert("Authorization".into(), format!("Basic {}", bad));

        let req = CheckRequest {
            attributes: Some(v3::AttributeContext {
                source: None,
                destination: None,
                request: Some(attribute_context::Request {
                    time: None,
                    http: Some(attribute_context::HttpRequest {
                        id: "".to_string(),
                        method: "".to_string(),
                        headers: headers,
                        header_map: None,
                        path: "".to_string(),
                        host: "".to_string(),
                        scheme: "".to_string(),
                        query: "".to_string(),
                        fragment: "".to_string(),
                        size: 0,
                        protocol: "".to_string(),
                        body: "".to_string(),
                        raw_body: vec![],
                    }),
                }),
                context_extensions: Default::default(),
                metadata_context: None,
                route_metadata_context: None,
                tls_session: None,
            }),
        };

        let resp = svc.check(Request::new(req)).await.unwrap();
        let status = resp.get_ref().status.as_ref().unwrap();
        assert_eq!(status.code, Code::PermissionDenied as i32);
        assert_eq!(status.message, "invalid basic auth credentials");
    }

    #[tokio::test]
    async fn test_jwt_valid() {
        let state = make_auth_state();
        let raw = BASE64_STANDARD.decode(&state.jwt_secret).unwrap();
        let token = create_jwt("service_role", 3600, &raw);
        let svc = AuthSvc::new(state);
        let mut headers = HashMap::new();
        headers.insert("Authorization".into(), format!("Bearer {}", token));

        let req = CheckRequest {
            attributes: Some(v3::AttributeContext {
                source: None,
                destination: None,
                request: Some(attribute_context::Request {
                    time: None,
                    http: Some(attribute_context::HttpRequest {
                        id: "".to_string(),
                        method: "".to_string(),
                        headers: headers,
                        header_map: None,
                        path: "".to_string(),
                        host: "".to_string(),
                        scheme: "".to_string(),
                        query: "".to_string(),
                        fragment: "".to_string(),
                        size: 0,
                        protocol: "".to_string(),
                        body: "".to_string(),
                        raw_body: vec![],
                    }),
                }),
                context_extensions: Default::default(),
                metadata_context: None,
                route_metadata_context: None,
                tls_session: None,
            }),
        };

        let resp = svc.check(Request::new(req)).await.unwrap();
        let status = resp.get_ref().status.as_ref().unwrap();
        assert_eq!(status.code, Code::Ok as i32);
    }

    #[tokio::test]
    async fn test_jwt_expired() {
        let state = make_auth_state();
        let raw = BASE64_STANDARD.decode(&state.jwt_secret).unwrap();
        let token = create_jwt("anon", -1, &raw);
        let svc = AuthSvc::new(state);
        let mut headers = HashMap::new();
        headers.insert("Authorization".into(), format!("Bearer {}", token));

        let req = CheckRequest {
            attributes: Some(v3::AttributeContext {
                source: None,
                destination: None,
                request: Some(attribute_context::Request {
                    time: None,
                    http: Some(attribute_context::HttpRequest {
                        id: "".to_string(),
                        method: "".to_string(),
                        headers: headers,
                        header_map: None,
                        path: "".to_string(),
                        host: "".to_string(),
                        scheme: "".to_string(),
                        query: "".to_string(),
                        fragment: "".to_string(),
                        size: 0,
                        protocol: "".to_string(),
                        body: "".to_string(),
                        raw_body: vec![],
                    }),
                }),
                context_extensions: Default::default(),
                metadata_context: None,
                route_metadata_context: None,
                tls_session: None,
            }),
        };

        let resp = svc.check(Request::new(req)).await.unwrap();
        let status = resp.get_ref().status.as_ref().unwrap();
        assert_eq!(status.code, Code::PermissionDenied as i32);
        assert_eq!(status.message, "JWT token has expired");
    }

    #[tokio::test]
    async fn test_apikey_fallback() {
        let state = make_auth_state();
        let raw = BASE64_STANDARD.decode(&state.jwt_secret).unwrap();
        let token = create_jwt("anon", 3600, &raw);
        let svc = AuthSvc::new(state);
        let mut headers = HashMap::new();
        headers.insert("apikey".into(), token);

        let req = CheckRequest {
            attributes: Some(v3::AttributeContext {
                source: None,
                destination: None,
                request: Some(attribute_context::Request {
                    time: None,
                    http: Some(attribute_context::HttpRequest {
                        id: "".to_string(),
                        method: "".to_string(),
                        headers: headers,
                        header_map: None,
                        path: "".to_string(),
                        host: "".to_string(),
                        scheme: "".to_string(),
                        query: "".to_string(),
                        fragment: "".to_string(),
                        size: 0,
                        protocol: "".to_string(),
                        body: "".to_string(),
                        raw_body: vec![],
                    }),
                }),
                context_extensions: Default::default(),
                metadata_context: None,
                route_metadata_context: None,
                tls_session: None,
            }),
        };

        let resp = svc.check(Request::new(req)).await.unwrap();
        let status = resp.get_ref().status.as_ref().unwrap();
        assert_eq!(status.code, Code::Ok as i32);
    }
}
