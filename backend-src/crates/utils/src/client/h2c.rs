use std::{
    pin::Pin,
    task::{Context, Poll},
};

use hyper::body::Incoming;
use hyper::client::conn::http2;
use hyper_util::{
    client::legacy::{Client, connect::HttpConnector},
    rt::TokioExecutor,
};
use tonic::body::Body;
use tower::Service;

pub struct H2cChannel {
    pub client: Client<HttpConnector, Body>,
}

impl Service<http::Request<Body>> for H2cChannel {
    type Response = http::Response<Incoming>;
    type Error = hyper::Error;
    type Future =
        Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>> + Send>>;

    fn poll_ready(&mut self, _: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        Poll::Ready(Ok(()))
    }

    fn call(&mut self, request: http::Request<Body>) -> Self::Future {
        let client = self.client.clone();

        Box::pin(async move {
            let origin = request.uri();

            let h2c_req = hyper::Request::builder()
                .uri(origin)
                .header(http::header::UPGRADE, "h2c")
                .body(Body::default())
                .unwrap();

            let res = client.request(h2c_req).await.unwrap();

            if res.status() != http::StatusCode::SWITCHING_PROTOCOLS {
                panic!("Our server didn't upgrade: {}", res.status());
            }

            let upgraded_io = hyper::upgrade::on(res).await.unwrap();

            // In an ideal world you would somehow cache this connection
            let (mut h2_client, conn) =
                http2::Builder::new(TokioExecutor::new())
                    .handshake(upgraded_io)
                    .await
                    .unwrap();
            tokio::spawn(conn);

            h2_client.send_request(request).await
        })
    }
}
