use crate::graph::Error;
use async_trait::async_trait;
use redis::{FromRedisValue, ToRedisArgs};
use redis_macros::{FromRedisValue, ToRedisArgs};
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashMap};
use std::fmt::Debug;
use uuid::Uuid;

#[derive(Clone, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub struct WorkflowDefinition {
    pub id: Uuid,
    pub name: String,
    pub graph: serde_json::Value,
    pub created_at: i64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub enum ExecutionStatus {
    Pending,
    Running,
    Completed,
    Failed,
    Skipped,
}

#[derive(Clone, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub struct ExecutionState {
    pub id: Uuid,
    pub workflow_id: Uuid,
    pub status: ExecutionStatus,
    pub input_params: BTreeMap<String, ParameterType>,
    pub started_at: i64,           // unix timestamp
    pub completed_at: Option<i64>, // unix timestamp
    pub error_message: Option<String>,
}

#[derive(Debug, Default, Clone, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub enum Condition {
    #[default]
    OnSuccess,
    OnFailure,
    RetryableFailure,
}

#[derive(Debug, Clone)]
pub enum NodeState {
    Waiting,
    Ready,
    Executing,
    Completed(Result<(), Error>),
}

#[derive(Clone, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub struct NodeExecutionResult {
    pub node_id: Uuid,
    pub status: ExecutionStatus,
    pub input_params: BTreeMap<String, ParameterType>,
    pub output_params: BTreeMap<String, ParameterType>,
    pub started_at: i64,
    pub completed_at: Option<i64>,
    pub error_message: Option<String>,
}

pub type Parameters = BTreeMap<String, ParameterType>;

#[derive(Debug, Clone, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub enum ParameterType {
    String(String),
    Number(f64),
    Boolean(bool),
    Object(HashMap<String, ParameterType>),
    Array(Box<ParameterType>),
}

pub trait EdgeContext: Send + Sync {
    fn set(&mut self, key: String, value: ParameterType);
    fn get(&self, key: &str) -> Option<&ParameterType>;
    fn params(&self) -> BTreeMap<String, ParameterType>;
}

#[async_trait]
pub trait Node:
    Debug + Default + Send + Sync
{
    /// Returns the unique identifier of the node.
    fn id(&self) -> Uuid;

    /// Returns the name of the node.
    fn name(&self) -> String;

    /// Returns a description of the node.
    fn description(&self) -> Option<String>;

    /// Returns whether the node is in a valid state.
    fn is_ok(&self) -> bool;

    /// Executes the node's logic and returns the updated context.
    async fn execute(&self, context: Parameters) -> Result<Parameters, Error>;
}

pub trait Edge:
    Debug + Default + Send + Sync
{
    /// Returns the unique identifier of the edge.
    fn id(&self) -> Uuid;

    /// Returns the source node's identifier.
    fn source(&self) -> Uuid;

    /// Returns the target node's identifier.
    fn target(&self) -> Uuid;

    /// Returns the condition of the preceding node that must be met for this edge to be followed.
    fn condition(&self) -> Condition;
}
