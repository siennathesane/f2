use crate::graph::types::{ExecutionState, ExecutionStatus, ParameterType, WorkflowDefinition};
use crate::graph::Error;
use crate::graph::Error::RedisError;
use redis::Client;
use std::collections::BTreeMap;
use uuid::Uuid;

pub struct WorkflowExecutor {
    client: Client,
}

impl WorkflowExecutor {
    pub async fn new(redis_url: &str) -> Result<Self, redis::RedisError> {
        let client = Client::open(redis_url)?;
        Ok(Self { client })
    }

    fn workflow_key(&self, workflow_id: &Uuid) -> String {
        format!("workflow:{}", workflow_id)
    }

    fn execution_key(&self, execution_id: &Uuid) -> String {
        format!("execution:{}", execution_id)
    }

    fn node_execution_key(&self, execution_id: &Uuid, node_idx: usize) -> String {
        format!("execution:{}:node:{}", execution_id, node_idx)
    }

    fn running_executions_key(&self) -> &'static str {
        "executions:running"
    }
}

impl WorkflowExecutor {
    pub async fn save_workflow(&self, workflow: &WorkflowDefinition) -> Result<(), Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("HMSET")
            .arg(self.workflow_key(&workflow.id))
            .arg(workflow)
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => Ok(()),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    pub async fn load_workflow(&self, workflow_id: Uuid) -> Result<WorkflowDefinition, Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("HGETALL")
            .arg(self.workflow_key(&workflow_id))
            .query_async::<WorkflowDefinition>(&mut conn)
            .await
        {
            Ok(v) => Ok(v),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }
    
    pub async fn save_execution_state(&self, state: &ExecutionState) -> Result<(), Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("HMSET")
            .arg(self.execution_key(&state.id))
            .arg(state)
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => Ok(()),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    pub async fn execute_workflow(
        &self,
        workflow_id: Uuid,
        input_params: BTreeMap<String, ParameterType>,
    ) -> Result<Uuid, Error> {
        let workflow = self.load_workflow(workflow_id).await?;
        let execution_id = Uuid::new_v4();
        
        let execution_state = ExecutionState {
            id: execution_id,
            workflow_id: workflow.id,
            status: ExecutionStatus::Running,
            input_params,
            started_at: chrono::Utc::now().timestamp(),
            completed_at: None,
            error_message: None,
        };
        
        self.save_execution_state(&execution_state).await?;
        
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("SADD")
            .arg(self.running_executions_key())
            .arg(&execution_id)
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => { },
            Err(e) => return Err(RedisError(e.to_string())),
        };
        
        // TODO(@siennathesane): implement the graph execution
        
        Ok(execution_id)
    }
}
