use std::pin::Pin;

use http::{Request, Response};
use hyper::body::Incoming;
use hyper::server::conn::http2;
use hyper_util::{rt::TokioExecutor, service::TowerToHyperService};
use tonic::body::Body;
use tower::{Service, ServiceExt};

#[derive(Clone)]
pub struct H2c<S> {
    s: S,
}

impl <S> H2c<S> {
    pub fn new(s: S) -> Self {
        Self { s }
    }
}

type BoxError = Box<dyn std::error::Error + Send + Sync>;

impl<S> Service<Request<Incoming>> for H2c<S>
where
    S: Service<Request<Body>, Response = Response<Body>> + Clone + Send + 'static,
    S::Future: Send,
    S::Error: Into<BoxError> + 'static,
{
    type Response = Response<Body>;
    type Error = hyper::Error;
    type Future =
    Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>> + Send>>;

    fn poll_ready(
        &mut self,
        _: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Result<(), Self::Error>> {
        std::task::Poll::Ready(Ok(()))
    }

    fn call(&mut self, req: hyper::Request<Incoming>) -> Self::Future {
        let mut req = req.map(Body::new);
        let svc = self
            .s
            .clone()
            .map_request(|req: Request<_>| req.map(Body::new));
        Box::pin(async move {
            tokio::spawn(async move {
                let upgraded_io = hyper::upgrade::on(&mut req).await.unwrap();

                http2::Builder::new(TokioExecutor::new())
                    .serve_connection(upgraded_io, TowerToHyperService::new(svc))
                    .await
                    .unwrap();
            });

            let mut res = hyper::Response::new(Body::default());
            *res.status_mut() = http::StatusCode::SWITCHING_PROTOCOLS;
            res.headers_mut().insert(
                hyper::header::UPGRADE,
                http::header::HeaderValue::from_static("h2c"),
            );

            Ok(res)
        })
    }
}
