use base64::Engine;
use base64::prelude::BASE64_STANDARD;
use chrono::Utc;
use jsonwebtoken::{Algorithm, DecodingKey, Validation, decode};
use serde::{Deserialize, Serialize};

pub(crate) mod extauth;

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    pub role: String,
    pub iss: String,
    pub iat: i64,
    pub exp: i64,
}

#[derive(Debug)]
enum VerificationResult {
    Valid { role: String, username: String },
    Invalid,
    Expired,
}

#[derive(Clone)]
pub(crate) struct AuthState {
    jwt_secret: String,
    dashboard_username: String,
    dashboard_password: String,
}

impl AuthState {
    pub(crate) fn new(
        jwt_secret: String,
        dashboard_username: String,
        dashboard_password: String,
    ) -> Self {
        Self {
            jwt_secret,
            dashboard_username,
            dashboard_password,
        }
    }

    fn verify_jwt(&self, token: &str) -> VerificationResult {
        // Create validation rules
        let mut validation = Validation::new(Algorithm::HS256);
        validation.set_issuer(&["f2", "supabase"]);

        let secret = match BASE64_STANDARD.decode(&self.jwt_secret) {
            Ok(decoded) => decoded,
            Err(e) => {
                tracing::error!("Failed to decode JWT secret: {}", e);
                return VerificationResult::Invalid;
            }
        };

        let decoding_key = DecodingKey::from_secret(&secret);

        match decode::<Claims>(token, &decoding_key, &validation) {
            Ok(token_data) => {
                let claims = token_data.claims;

                // Check if token is expired
                let now = Utc::now().timestamp();
                if claims.exp < now {
                    tracing::warn!("JWT token expired. exp: {}, now: {}", claims.exp, now);
                    return VerificationResult::Expired;
                }

                // Determine username based on role
                let username = match claims.role.as_str() {
                    "anon" => "anon".to_string(),
                    "service_role" => "service_role".to_string(),
                    _ => {
                        tracing::warn!("Unknown role in JWT: {}", claims.role);
                        return VerificationResult::Invalid;
                    }
                };

                tracing::debug!("JWT verified successfully for role: {}", claims.role);
                VerificationResult::Valid {
                    role: claims.role,
                    username,
                }
            }
            Err(e) => {
                println!("JWT verification failed: {e}");
                tracing::warn!("JWT verification failed: {}", e);
                VerificationResult::Invalid
            }
        }
    }

    fn verify_basic_auth(&self, base64_credentials: &str) -> Result<(), &'static str> {
        match BASE64_STANDARD.decode(base64_credentials) {
            Ok(decoded) => {
                if let Ok(credentials) = String::from_utf8(decoded) {
                    if let Some((username, password)) = credentials.split_once(':') {
                        if username == &self.dashboard_username
                            && password == &self.dashboard_password
                        {
                            return Ok(());
                        }
                    }
                }
            }
            Err(_) => return Err("Invalid base64 encoding"),
        }
        Err("Invalid credentials")
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use base64::Engine;
    use base64::prelude::BASE64_STANDARD;
    use chrono::Utc;
    use jsonwebtoken::{Algorithm, EncodingKey, Header, encode};

    fn make_auth_state() -> AuthState {
        // Use "secret" as raw secret, base64-encode for AuthState
        let raw_secret = b"secret";
        let jwt_secret = BASE64_STANDARD.encode(raw_secret);
        AuthState::new(jwt_secret, "admin".into(), "s3cr3t".into())
    }

    #[test]
    fn verify_basic_auth_success() {
        let state = make_auth_state();
        let creds = format!("admin:s3cr3t");
        let encoded = BASE64_STANDARD.encode(creds.as_bytes());
        assert!(state.verify_basic_auth(&encoded).is_ok());
    }

    #[test]
    fn verify_basic_auth_failure() {
        let state = make_auth_state();
        let bad = BASE64_STANDARD.encode(b"admin:wrong");
        assert!(state.verify_basic_auth(&bad).is_err());
    }

    #[test]
    fn role_to_group_mappings() {
        let state = make_auth_state();
        assert_eq!(state.role_to_group("anon"), "anon");
        assert_eq!(state.role_to_group("service_role"), "admin");
        assert_eq!(state.role_to_group("something_else"), "anon");
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
        .expect("JWT creation failed")
    }

    #[test]
    fn verify_jwt_valid_token() {
        let state = make_auth_state();
        let raw_secret = BASE64_STANDARD.decode(&state.jwt_secret).unwrap();
        let token = create_jwt("anon", 3600, &raw_secret);
        match state.verify_jwt(&token) {
            VerificationResult::Valid { role, username } => {
                assert_eq!(role, "anon");
                assert_eq!(username, "anon");
            }
            other => panic!("Expected Valid, got {:?}", other),
        }
    }

    #[test]
    fn verify_jwt_expired_token() {
        let state = make_auth_state();
        let raw_secret = BASE64_STANDARD.decode(&state.jwt_secret).unwrap();
        let token = create_jwt("service_role", -1, &raw_secret);
        assert!(matches!(
            state.verify_jwt(&token),
            VerificationResult::Expired
        ));
    }

    #[test]
    fn verify_jwt_invalid_signature() {
        let state = make_auth_state();
        // Sign with wrong secret
        let token = create_jwt("anon", 3600, b"wrongsecret");
        assert!(matches!(
            state.verify_jwt(&token),
            VerificationResult::Invalid
        ));
    }
}
