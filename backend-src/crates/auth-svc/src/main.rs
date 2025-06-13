use crate::jwt::extauth::AuthSvc;
use envoy_types::ext_authz::v3::pb::AuthorizationServer;
use f2_utils::server::h2c::H2c;
use hyper_util::rt::{TokioExecutor, TokioIo};
use hyper_util::server::conn::auto::Builder;
use hyper_util::service::TowerToHyperService;
use std::env;
use std::sync::Arc;
use tokio::net::TcpListener;
use tonic::service::Routes;

mod jwt;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt().init();

    let jwt_secret = env::var("JWT_SECRET")
        .map_err(|_| anyhow::anyhow!("JWT_SECRET environment variable not set"))?;

    let dashboard_username = env::var("DASHBOARD_USERNAME")
        .map_err(|_| anyhow::anyhow!("DASHBOARD_USERNAME environment variable not set"))?;

    let dashboard_password = env::var("DASHBOARD_PASSWORD")
        .map_err(|_| anyhow::anyhow!("DASHBOARD_PASSWORD environment variable not set"))?;

    let state = Arc::new(jwt::AuthState::new(
        jwt_secret,
        dashboard_username,
        dashboard_password,
    ));

    let auth_server = AuthorizationServer::new(AuthSvc::new(state.clone()));

    let port = env::var("PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()
        .unwrap_or(8080);

    tracing::info!("Starting auth service on port {}", port);

    let routes = Routes::new(auth_server).prepare();
    let server = H2c::new(routes);
    let listener = TcpListener::bind(format!("0.0.0.0:{port}")).await?;

    loop {
        match listener.accept().await {
            Ok((io, _)) => {
                let router = server.clone();
                tokio::spawn(async move {
                    let builder = Builder::new(TokioExecutor::new());
                    let conn = builder.serve_connection_with_upgrades(
                        TokioIo::new(io),
                        TowerToHyperService::new(router),
                    );
                    let _ = conn.await;
                });
            }
            Err(e) => {
                eprintln!("Error accepting connection: {e}");
            }
        }
    }
}
