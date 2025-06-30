use thiserror::Error;

mod core;
mod edge_ctx;
mod executor;
pub mod macros;
pub mod types;

#[derive(Error, Debug, Clone)]
pub enum Error {
    #[error("Invalid input: {0}")]
    InvalidInput(String),
    #[error("Execution failed: {0}")]
    ExecutionFailed(String),
    #[error("Serialization error: {0}")]
    SerializationError(String),
    #[error("Deserialization error: {0}")]
    DeserializationError(String),
    #[error("Redis error: {0}")]
    RedisError(String),
}
