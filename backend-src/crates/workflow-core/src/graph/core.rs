use crate::graph::edge_ctx::EdgeCtx;
use crate::graph::types::{
    Condition, Edge, EdgeContext, ExecutionState, ExecutionStatus, Node, NodeExecutionResult,
    NodeState, ParameterType,
};
use crate::graph::Error;
use crate::graph::Error::RedisError;
use dyn_clone::clone_box;
use petgraph::graph::NodeIndex;
use petgraph::prelude::EdgeRef;
use petgraph::{Directed, Graph};
use redis::Client;
use std::collections::{BTreeMap, HashSet};
use std::sync::{Arc, Mutex};
use tokio::sync::mpsc;
use uuid::Uuid;

#[derive(Clone)]
pub struct Workflow {
    id: Uuid,
    graph: Arc<Graph<Box<dyn Node>, Box<dyn Edge>, Directed>>,
    client: Arc<Client>,
}

impl Workflow {
    pub fn new(client: Client) -> Arc<Self> {
        Arc::new(Workflow {
            id: Uuid::new_v4(),
            graph: Arc::new(Graph::new()),
            client: Arc::new(client),
        })
    }

    pub async fn get_execution_state(
        self: Arc<Self>,
        execution_id: Uuid,
    ) -> Result<ExecutionState, Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("HGETALL")
            .arg(self.execution_key(&execution_id))
            .query_async(&mut conn)
            .await
        {
            Ok(v) => Ok(v),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    pub async fn clear_execution_state(self: Arc<Self>, execution_id: &Uuid) -> Result<(), Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("SREM")
            .arg(self.clone().running_executions_key())
            .arg(execution_id.to_string())
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => {}
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("DEL")
            .arg(self.execution_key(execution_id))
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => Ok(()),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    /// Executes the workflow with the given execution ID and initial parameters.
    // TODO(@siennathesane): add support for cancellation, timeouts, and streaming
    pub async fn execute(
        self: Arc<Self>,
        execution_id: Uuid,
        initial_params: BTreeMap<String, ParameterType>,
    ) -> Result<(), crate::graph::Error> {
        let execution_state = ExecutionState {
            id: execution_id,
            workflow_id: self.id,
            status: ExecutionStatus::Running,
            input_params: initial_params.clone(),
            started_at: chrono::Utc::now().timestamp_millis(),
            completed_at: None,
            error_message: None,
        };

        match self.clone().save_execution_state(&execution_state).await {
            Ok(_) => {}
            Err(e) => return Err(e),
        }

        let node_states = Arc::new(Mutex::new(BTreeMap::new()));
        let node_contexts = Arc::new(Mutex::new(BTreeMap::new()));
        let completed_nodes = Arc::new(Mutex::new(HashSet::new()));

        let (result_tx, mut result_rx) = mpsc::unbounded_channel();
        let (ready_tx, mut ready_rx) = mpsc::unbounded_channel();

        // identify & queue the top-level nodes
        for node_idx in self.clone().graph.node_indices() {
            let has_incoming = self
                .clone()
                .graph
                .edges_directed(node_idx, petgraph::Incoming)
                .count()
                > 0;

            if !has_incoming {
                let context = self.clone().create_initial_context(&initial_params);
                node_contexts.lock().unwrap().insert(node_idx, context);

                node_states
                    .lock()
                    .unwrap()
                    .insert(node_idx, NodeState::Ready);
                ready_tx.send(node_idx).unwrap();
            } else {
                node_states
                    .lock()
                    .unwrap()
                    .insert(node_idx, NodeState::Waiting);
            }
        }

        // Don't share the receiver - handle ready nodes in main task
        let mut ready_rx = ready_rx;

        // Process both ready nodes and execution results concurrently
        let total_nodes = self.clone().graph.node_count();
        let mut completed_count = 0;

        // Process initial ready nodes and handle results
        loop {
            tokio::select! {
                // Handle ready nodes
                Some(ready_node_idx) = ready_rx.recv() => {
                    // Get the node and prepare data for the spawned task
                    let node = clone_box(&*self.clone().graph[ready_node_idx]);
                    let result_tx = result_tx.clone();
                    let workflow_id = self.clone().id;
                    let workflow = Arc::clone(&self);

                    // Spawn individual node execution task
                    tokio::spawn(async move {
                        let start_time = chrono::Utc::now().timestamp_millis();

                        // Create a simple context (you'll implement proper parameter handling later)
                        let context = Box::new(EdgeCtx {
                            id: Uuid::new_v4(),
                            params: BTreeMap::new(),
                            idx: 0,
                        }) as Box<dyn EdgeContext>;

                        match node.execute(&context).await {
                            Ok(ctx) => {
                                let input_params = workflow.clone().get_node_input_params(execution_id, ready_node_idx).await.unwrap_or_default();

                                // Create execution result
                                let execution_result = NodeExecutionResult {
                                    node_id: node.id(),
                                    status: ExecutionStatus::Completed,
                                    input_params,
                                    output_params: workflow.clone().extract_params_from_context(&ctx),
                                    started_at: start_time,
                                    completed_at: Some(chrono::Utc::now().timestamp_millis()),
                                    error_message: None,
                                };

                                // Store the result
                                workflow.store_node_result(workflow_id, node.id(), execution_result).await.unwrap();
                                result_tx.send((ready_node_idx, Ok(()), ctx)).unwrap()
                            },
                            Err(e) => {
                                let error_result = NodeExecutionResult {
                                    node_id: node.id(),
                                    status: ExecutionStatus::Failed,
                                    input_params: context.params(),
                                    output_params: BTreeMap::new(),
                                    started_at: start_time,
                                    completed_at: Some(chrono::Utc::now().timestamp_millis()),
                                    error_message: Some(e.to_string()),
                                };
                                workflow.store_node_result(workflow_id, node.id(), error_result).await.unwrap();
                                let output_params: Box<dyn EdgeContext> = Box::new(EdgeCtx::default());
                                result_tx.send((ready_node_idx, Err(e), output_params)).unwrap()
                            },
                        }
                    });
                }

                // Handle execution results
                Some((completed_idx, result, _output_params)) = result_rx.recv() => {
                    // Update node state
                    let node_state = match result {
                        Ok(_) => NodeState::Completed(Ok(())),
                        Err(e) => NodeState::Completed(Err(e)),
                    };

                    node_states.lock().unwrap().insert(completed_idx, node_state);
                    completed_nodes.lock().unwrap().insert(completed_idx);
                    completed_count += 1;

                    // Check dependent nodes
                    for edge_ref in self.clone().graph.edges_directed(completed_idx, petgraph::Outgoing) {
                        let target_idx = edge_ref.target();

                        // For now, simple dependency check (you'll implement proper dependency logic later)
                        let current_state = node_states.lock().unwrap().get(&target_idx).cloned();
                        if matches!(current_state, Some(NodeState::Waiting)) {
                            node_states.lock().unwrap().insert(target_idx, NodeState::Ready);
                            ready_tx.send(target_idx).unwrap();
                        }
                    }

                    // Check if workflow is complete
                    if completed_count >= total_nodes {
                        break;
                    }
                }
            }
        }

        // Update final execution state
        let mut final_execution_state = self.clone().get_execution_state(execution_id).await?;
        final_execution_state.status = ExecutionStatus::Completed;
        final_execution_state.completed_at = Some(chrono::Utc::now().timestamp_millis());

        self.clone()
            .save_execution_state(&final_execution_state)
            .await?;
        self.clone().clear_execution_state(&execution_id).await?;

        Ok(())
    }

    async fn save_execution_state(self: Arc<Self>, state: &ExecutionState) -> Result<(), Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("HMSET")
            .arg(self.clone().execution_key(&state.id))
            .arg(state)
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => {}
            Err(e) => return Err(RedisError(e.to_string())),
        };
        match redis::cmd("SADD")
            .arg(self.running_executions_key())
            .arg(state.id.to_string())
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => Ok(()),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    /// Checks if all dependencies of the target node are met based on the completed nodes.
    async fn all_dependencies_met(
        self: Arc<Self>,
        target_idx: NodeIndex,
        completed_nodes: Arc<Mutex<HashSet<NodeIndex>>>,
    ) -> bool {
        let completed = completed_nodes.lock().unwrap();

        // check all the incoming nodes
        for edge_ref in self.graph.edges_directed(target_idx, petgraph::Incoming) {
            let source_idx = edge_ref.source();
            let edge = edge_ref.weight();

            if let Some(source_idx) = completed.get(&source_idx) {
                let source_result = &self.graph[*source_idx];

                let condition_met = matches!(
                    (source_result.is_ok(), edge.condition()),
                    (true, Condition::OnSuccess)
                        | (false, Condition::OnFailure)
                        | (false, Condition::RetryableFailure)
                );

                if !condition_met {
                    // dependency not met
                    return false;
                }
            } else {
                // source hasn't completed yet
                return false;
            }
        }

        true
    }

    async fn get_node_input_params(
        self: Arc<Self>,
        execution_id: Uuid,
        node_idx: NodeIndex,
    ) -> Result<BTreeMap<String, ParameterType>, Error> {
        // For top-level nodes, return initial params
        let has_incoming = self
            .clone()
            .graph
            .edges_directed(node_idx, petgraph::Incoming)
            .count()
            > 0;

        if !has_incoming {
            let execution = self.clone().get_execution_state(execution_id).await?;
            Ok(execution.input_params)
        } else {
            // Merge parameters from all successful predecessor nodes
            let mut merged_params = BTreeMap::new();

            for edge_ref in self
                .clone()
                .graph
                .edges_directed(node_idx, petgraph::Incoming)
            {
                let source_node_id = self.clone().graph[edge_ref.source()].id();
                if let Some(source_result) = self
                    .clone()
                    .get_node_result(execution_id, source_node_id)
                    .await?
                {
                    if source_result.status == ExecutionStatus::Completed {
                        merged_params.extend(source_result.output_params);
                    }
                }
            }

            Ok(merged_params)
        }
    }

    /// Retrieves the result of a node execution.
    async fn get_node_result(
        self: Arc<Self>,
        execution_id: Uuid,
        node_id: Uuid,
    ) -> Result<Option<NodeExecutionResult>, Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };

        let key = self.node_execution_key(&execution_id, node_id);

        match redis::cmd("HGETALL").arg(&key).query_async(&mut conn).await {
            Ok(v) => Ok(Some(v)),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    async fn store_node_result(
        self: Arc<Self>,
        execution_id: Uuid,
        node_id: Uuid,
        result: NodeExecutionResult,
    ) -> Result<(), Error> {
        let mut conn = match self.client.get_multiplexed_async_connection().await {
            Ok(v) => v,
            Err(e) => return Err(RedisError(e.to_string())),
        };

        let key = self.node_execution_key(&execution_id, node_id);

        match redis::cmd("HMSET")
            .arg(&key)
            .arg(result)
            .exec_async(&mut conn)
            .await
        {
            Ok(_) => Ok(()),
            Err(e) => Err(RedisError(e.to_string())),
        }
    }

    // Helper function to create initial context
    fn create_initial_context(
        self: Arc<Self>,
        params: &BTreeMap<String, ParameterType>,
    ) -> Box<dyn EdgeContext> {
        let mut context = EdgeCtx {
            id: Uuid::new_v4(),
            params: BTreeMap::new(),
            ..Default::default()
        };
        for (key, value) in params {
            context.set(key.clone(), value.clone());
        }
        Box::new(context)
    }

    fn extract_params_from_context(
        self: Arc<Self>,
        context: &Box<dyn EdgeContext>,
    ) -> BTreeMap<String, ParameterType> {
        let mut params = BTreeMap::new();
        for (key, _) in context.params() {
            if let Some(param) = context.get(key.as_str()) {
                params.insert(key.clone(), param.clone());
            }
        }
        params
    }

    fn workflow_key(self: Arc<Self>, workflow_id: &Uuid) -> String {
        format!("workflow:{workflow_id}")
    }

    fn execution_key(self: Arc<Self>, execution_id: &Uuid) -> String {
        format!("workflow:{}:execution:{execution_id}", self.id)
    }

    fn node_execution_key(self: Arc<Self>, execution_id: &Uuid, node_id: Uuid) -> String {
        format!(
            "workflow:{}:execution:{execution_id}:node:{node_id}",
            self.id
        )
    }

    fn running_executions_key(self: Arc<Self>) -> &'static str {
        "executions:running"
    }
}
