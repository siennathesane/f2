FROM rustlang/rust:nightly-alpine3.22 as builder
WORKDIR /usr/src/myapp
COPY . .
RUN cd auth-svc && apk add musl-dev && cargo install --path .

FROM alpine:latest
COPY --from=builder /usr/local/cargo/bin/auth-svc /usr/bin/auth-svc
CMD ["/usr/bin/auth-svc"]
