## Compiling for Swift Native

Download and compile the `protoc` compiler plugins for Protobufs and gRPC.

```shell
git clone https://github.com/apple/swift-protobuf
pushd swift-protobuf
swift build -c release
cp .build/arm64-apple-macosx/release/protoc-gen-swift ~/.bin/
popd

gh repo clone grpc/grpc-swift-protobuf
pushd grpc-swift-protobuf
swift build -c release --product protoc-gen-grpc-swift-2
cp .build/arm64-apple-macosx/release/protoc-gen-grpc-swift-2 ~/.bin/
popd
```

## Compiling for Kotlin Native

Download and compile the `protoc` compiler plugins for Protobufs and gRPC.
