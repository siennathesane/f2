use thiserror::Error;

mod executor;
mod edge_ctx;
pub mod macros;
mod params_node;
pub mod types;
mod core;

#[derive(Error, Debug, Clone)]
pub enum Error {
    #[error("Node not found: {0}")]
    NodeNotFound(String),
    #[error("Node already exists: {0}")]
    NodeAlreadyExists(String),
    #[error("Edge not found: {0}")]
    EdgeNotFound(String),
    #[error("Edge already exists: {0}")]
    EdgeAlreadyExists(String),
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
