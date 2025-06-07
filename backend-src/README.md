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

```shell
wget https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-kotlin/1.4.3/protoc-gen-grpc-kotlin-1.4.3-jdk8.jar
mv protoc-gen-grpc-kotlin-1.4.3-jdk8.jar ~/.bin/protoc-gen-grpc-kotlin.jar
cat <<EOF > ~/.bin/protoc-gen-grpc-kotlin
java -jar HOME/.bin/protoc-gen-grpc-kotlin.jar "$@"
EOF
chmod +x ~/.bin/protoc-gen-grpc-kotlin
```