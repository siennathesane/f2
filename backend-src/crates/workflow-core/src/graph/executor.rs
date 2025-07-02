// use crate::graph::Error;
// use crate::graph::Error::RedisError;
// use crate::graph::edge_ctx::EdgeCtx;
// use crate::graph::types::{
//     Condition, Edge, EdgeContext, ExecutionState, ExecutionStatus, Node,
//     NodeExecutionResult, NodeState, ParameterType,
// };
// use dyn_clone::clone_box;
// use futures::StreamExt;
// use futures::stream::FuturesUnordered;
// use petgraph::graph::NodeIndex;
// use petgraph::prelude::EdgeRef;
// use petgraph::{Directed, Graph};
// use redis::Client;
// use std::collections::{BTreeMap, HashSet};
// use std::sync::{Arc, Mutex};
// use tokio::sync::mpsc;
// use uuid::Uuid;
// 
// pub struct Workflow {
//     id: Uuid,
//     graph: Graph<Box<dyn Node>, Box<dyn Edge>, Directed, IndexType>,
//     client: Arc<Client>,
// }
// 
// impl Workflow {
//     pub fn new(client: Client) -> Arc<Self> {
//         Arc::new(Workflow {
//             id: Uuid::new_v4(),
//             graph: Graph::<Box<dyn Node>, Box<dyn Edge>, Directed, IndexType>::default(),
//             client: Arc::new(client),
//         })
//     }
// 
//     pub async fn get_execution_state(&self, execution_id: Uuid) -> Result<ExecutionState, Error> {
//         let mut conn = match self.client.get_multiplexed_async_connection().await {
//             Ok(v) => v,
//             Err(e) => return Err(RedisError(e.to_string())),
//         };
//         match redis::cmd("HGETALL")
//             .arg(self.execution_key(&execution_id))
//             .query_async(&mut conn)
//             .await
//         {
//             Ok(v) => Ok(v),
//             Err(e) => Err(RedisError(e.to_string())),
//         }
//     }
// 
//     pub async fn clear_execution_state(&self, execution_id: &Uuid) -> Result<(), Error> {
//         let mut conn = match self.client.get_multiplexed_async_connection().await {
//             Ok(v) => v,
//             Err(e) => return Err(RedisError(e.to_string())),
//         };
//         match redis::cmd("SREM")
//             .arg(self.clone().running_executions_key())
//             .arg(execution_id.to_string())
//             .exec_async(&mut conn)
//             .await
//         {
//             Ok(_) => Ok(()),
//             Err(e) => Err(RedisError(e.to_string())),
//         }
//     }
// 
//     /// Executes the workflow with the given execution ID and initial parameters.
//     // TODO(@siennathesane): add support for cancellation, timeouts, and streaming
//     pub async fn execute(
//         &mut self,
//         execution_id: Uuid,
//         initial_params: BTreeMap<String, ParameterType>,
//     ) -> Result<(), crate::graph::Error> {
//         let execution_state = ExecutionState {
//             id: execution_id,
//             workflow_id: self.id,
//             status: ExecutionStatus::Running,
//             input_params: initial_params.clone(),
//             started_at: chrono::Utc::now().timestamp_millis(),
//             completed_at: None,
//             error_message: None,
//         };
// 
//         match self.save_execution_state(&execution_state).await {
//             Ok(_) => {}
//             Err(e) => return Err(e),
//         }
// 
//         let node_states = Arc::new(Mutex::new(BTreeMap::new()));
//         let node_contexts = Arc::new(Mutex::new(BTreeMap::new()));
//         let completed_nodes = Arc::new(Mutex::new(HashSet::new()));
// 
//         // let (result_tx, mut result_rx) = mpsc::unbounded_channel();
//         let (ready_tx, mut ready_rx) = mpsc::unbounded_channel();
// 
//         // identify & queue the top-level nodes
//         for node_idx in self.graph.node_indices() {
//             let has_incoming = self
//                 .graph
//                 .edges_directed(node_idx, petgraph::Incoming)
//                 .count()
//                 > 0;
// 
//             if !has_incoming {
//                 let context = self.create_initial_context(&initial_params);
//                 node_contexts.lock().unwrap().insert(node_idx, context);
// 
//                 node_states
//                     .lock()
//                     .unwrap()
//                     .insert(node_idx, NodeState::Ready);
//                 ready_tx.send(node_idx).unwrap();
//             } else {
//                 node_states
//                     .lock()
//                     .unwrap()
//                     .insert(node_idx, NodeState::Waiting);
//             }
//         }
// 
//         let total_nodes = self.graph.node_count();
//         let mut completed_count = 0;
//         let mut pending_tasks = FuturesUnordered::new();
// 
//         loop {
//             while let Ok(ready_node_idx) = ready_rx.try_recv() {
//                 let node = clone_box(&*self.graph[ready_node_idx]);
// 
//                 let input_params = self
//                     .get_node_input_params(execution_id, ready_node_idx)
//                     .await?;
// 
//                 let task = tokio::spawn(async move {
//                     let start_time = chrono::Utc::now().timestamp_millis();
// 
//                     // TODO(@siennathesane): add support for node input parameters
//                     let context = Box::new(EdgeCtx {
//                         id: Uuid::new_v4(),
//                         params: BTreeMap::new(), // TODO: proper params
//                         idx: 0,
//                     }) as Box<dyn EdgeContext>;
// 
//                     let result = node.execute(&context).await;
// 
//                     // Return node info with result
//                     (ready_node_idx, result, start_time)
//                 });
// 
//                 pending_tasks.push(task);
//             }
// 
//             // handle execution results
//             if let Some(task_result) = pending_tasks.next().await {
//                 match task_result {
//                     Ok((completed_idx, execution_result, start_time)) => {
//                         completed_count += 1;
// 
//                         // Update node state
//                         let node_state = match execution_result {
//                             Ok(_) => NodeState::Completed(Ok(())),
//                             Err(e) => NodeState::Completed(Err(e)),
//                         };
//                         node_states
//                             .lock()
//                             .unwrap()
//                             .insert(completed_idx, node_state);
//                         completed_nodes.lock().unwrap().insert(completed_idx);
//                     }
//                     Err(join_error) => {
//                         // TODO(@siennathesane): handle task panics gracefully
//                         return Err(Error::ExecutionFailed(format!(
//                             "Task panicked: {}",
//                             join_error
//                         )));
//                     }
//                 }
//             }
// 
//             if completed_count >= total_nodes && pending_tasks.is_empty() {
//                 break;
//             }
// 
//             if pending_tasks.is_empty() && completed_count < total_nodes {
//                 return Err(Error::ExecutionFailed(
//                     "Workflow deadlocked - no pending tasks but not complete".to_string(),
//                 ));
//             }
//         }
// 
//         let mut final_execution_state = self.get_execution_state(execution_id).await?;
//         final_execution_state.status = ExecutionStatus::Completed;
//         final_execution_state.completed_at = Some(chrono::Utc::now().timestamp_millis());
// 
//         self.save_execution_state(&final_execution_state).await?;
//         self.clear_execution_state(&execution_id).await?;
// 
//         Ok(())
//     }
// 
//     async fn save_execution_state(&self, state: &ExecutionState) -> Result<(), Error> {
//         let mut conn = match self.client.get_multiplexed_async_connection().await {
//             Ok(v) => v,
//             Err(e) => return Err(RedisError(e.to_string())),
//         };
//         match redis::cmd("HMSET")
//             .arg(self.execution_key(&state.id))
//             .arg(state)
//             .exec_async(&mut conn)
//             .await
//         {
//             Ok(_) => {}
//             Err(e) => return Err(RedisError(e.to_string())),
//         };
//         match redis::cmd("SADD")
//             .arg(self.running_executions_key())
//             .arg(state.id.to_string())
//             .exec_async(&mut conn)
//             .await
//         {
//             Ok(_) => Ok(()),
//             Err(e) => Err(RedisError(e.to_string())),
//         }
//     }
// 
//     /// Checks if all dependencies of the target node are met based on the completed nodes.
//     async fn all_dependencies_met(
//         &self,
//         target_idx: NodeIndex,
//         completed_nodes: Arc<Mutex<HashSet<NodeIndex>>>,
//     ) -> bool {
//         let completed = completed_nodes.lock().unwrap();
// 
//         // check all the incoming nodes
//         for edge_ref in self.graph.edges_directed(target_idx, petgraph::Incoming) {
//             let source_idx = edge_ref.source();
//             let edge = edge_ref.weight();
// 
//             if let Some(source_idx) = completed.get(&source_idx) {
//                 let source_result = &self.graph[*source_idx];
// 
//                 let condition_met = matches!(
//                     (source_result.is_ok(), edge.condition()),
//                     (true, Condition::OnSuccess)
//                         | (false, Condition::OnFailure)
//                         | (false, Condition::RetryableFailure)
//                 );
// 
//                 if !condition_met {
//                     // dependency not met
//                     return false;
//                 }
//             } else {
//                 // source hasn't completed yet
//                 return false;
//             }
//         }
// 
//         true
//     }
// 
//     async fn get_node_input_params(
//         &mut self,
//         execution_id: Uuid,
//         node_idx: IndexType,
//     ) -> Result<Box<dyn EdgeContext>, Error> {
//         let has_incoming = self
//             .graph
//             .edges_directed(node_idx, petgraph::Incoming)
//             .count()
//             > 0;
// 
//         let mut merged_context = Box::new(EdgeCtx {
//             id: Uuid::new_v4(),
//             params: BTreeMap::new(),
//             idx: node_idx.index() as u32,
//         }) as Box<dyn EdgeContext>;
//         merged_context.set(
//             "execution_id".to_string(),
//             ParameterType::String(execution_id.to_string()),
//         );
// 
//         if !has_incoming {
//             // top-level node, return initial parameters
//             let execution = self.get_execution_state(execution_id).await?;
//             for (key, value) in execution.input_params {
//                 merged_context.set(key, value);
//             }
//             Ok(merged_context)
//         } else {
//             for edge_ref in self.graph.edges_directed(node_idx, petgraph::Incoming) {
//                 let source_node_id = self.graph[edge_ref.source()].id();
//                 if let Some(source_result) =
//                     self.get_node_result(execution_id, source_node_id).await?
//                 {
//                     if source_result.status == ExecutionStatus::Completed {
//                         for (key, value) in source_result.output_params {
//                             merged_context.set(key, value);
//                         }
//                     }
//                 }
//             }
// 
//             Ok(merged_context)
//         }
//     }
// 
//     /// Retrieves the result of a node execution.
//     async fn get_node_result(
//         &self,
//         execution_id: Uuid,
//         node_id: Uuid,
//     ) -> Result<Option<NodeExecutionResult>, Error> {
//         let mut conn = match self.client.get_multiplexed_async_connection().await {
//             Ok(v) => v,
//             Err(e) => return Err(RedisError(e.to_string())),
//         };
// 
//         let key = self.node_execution_key(&execution_id, node_id);
// 
//         match redis::cmd("HGETALL").arg(&key).query_async(&mut conn).await {
//             Ok(v) => Ok(Some(v)),
//             Err(e) => Err(RedisError(e.to_string())),
//         }
//     }
// 
//     async fn store_node_result(
//         &self,
//         execution_id: Uuid,
//         node_id: Uuid,
//         result: NodeExecutionResult,
//     ) -> Result<(), Error> {
//         let mut conn = match self.client.get_multiplexed_async_connection().await {
//             Ok(v) => v,
//             Err(e) => return Err(RedisError(e.to_string())),
//         };
// 
//         let key = self.node_execution_key(&execution_id, node_id);
// 
//         match redis::cmd("HMSET")
//             .arg(&key)
//             .arg(result)
//             .exec_async(&mut conn)
//             .await
//         {
//             Ok(_) => Ok(()),
//             Err(e) => Err(RedisError(e.to_string())),
//         }
//     }
// 
//     // Helper function to create initial context
//     fn create_initial_context(
//         &self,
//         params: &BTreeMap<String, ParameterType>,
//     ) -> Box<dyn EdgeContext> {
//         let mut context = EdgeCtx {
//             id: Uuid::new_v4(),
//             params: BTreeMap::new(),
//             ..Default::default()
//         };
//         for (key, value) in params {
//             context.set(key.clone(), value.clone());
//         }
//         Box::new(context)
//     }
// 
//     fn extract_params_from_context(
//         &self,
//         context: &Box<dyn EdgeContext>,
//     ) -> BTreeMap<String, ParameterType> {
//         let mut params = BTreeMap::new();
//         for (key, _) in context.params() {
//             if let Some(param) = context.get(key.as_str()) {
//                 params.insert(key.clone(), param.clone());
//             }
//         }
//         params
//     }
// 
//     fn workflow_key(&self, workflow_id: &Uuid) -> String {
//         format!("workflow:{workflow_id}")
//     }
// 
//     fn execution_key(&self, execution_id: &Uuid) -> String {
//         format!("workflow:{}:execution:{execution_id}", self.id)
//     }
// 
//     fn node_execution_key(&self, execution_id: &Uuid, node_id: Uuid) -> String {
//         format!(
//             "workflow:{}:execution:{execution_id}:node:{node_id}",
//             self.id
//         )
//     }
// 
//     fn running_executions_key(&self) -> &'static str {
//         "executions:running"
//     }
// }
