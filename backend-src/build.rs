fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_transport(true)
        .build_server(true)
        .build_client(true)
        .out_dir("src/api")
        .compile_protos(
            &["proto/f2/users/v1/users.proto"],
            &["proto/"],
        )?;
    Ok(())
}
