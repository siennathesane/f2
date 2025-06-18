use async_trait::async_trait;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use crate::models::error::WorkflowResult;
use crate::event::{Event, EventSubscription};
use std::collections::HashMap;

/// Core persistence provider trait for workflow data
/// 
/// This trait defines the interface for persisting workflow instances,
/// events, subscriptions, and execution history. Implementations can
/// use PostgreSQL, Redis, MongoDB, or other stores.
#[async_trait]
pub trait PersistenceProvider: Send + Sync {
    /// Initialize the persistence store (create tables, indexes, etc.)
    async fn initialize(&self) -> WorkflowResult<()>;

    /// Check if the persistence store is healthy
    async fn health_check(&self) -> WorkflowResult<bool>;

    // Workflow instance operations
    
    /// Create a new workflow instance
    async fn create_workflow_instance(&self, instance: &WorkflowInstanceData) -> WorkflowResult<()>;

    /// Update an existing workflow instance
    async fn update_workflow_instance(&self, instance: &WorkflowInstanceData) -> WorkflowResult<()>;

    /// Get a workflow instance by ID
    async fn get_workflow_instance(&self, id: Uuid) -> WorkflowResult<Option<WorkflowInstanceData>>;

    /// Get multiple workflow instances with filtering
    async fn get_workflow_instances(
        &self,
        filter: &WorkflowInstanceFilter,
    ) -> WorkflowResult<Vec<WorkflowInstanceData>>;

    /// Delete a workflow instance and all related data
    async fn delete_workflow_instance(&self, id: Uuid) -> WorkflowResult<()>;

    /// Get the next workflow instances ready for execution
    async fn get_runnable_instances(&self, limit: u32) -> WorkflowResult<Vec<WorkflowInstanceData>>;

    // Execution pointer operations
    
    /// Create execution pointers for a workflow instance
    async fn create_execution_pointers(
        &self,
        workflow_id: Uuid,
        pointers: &[ExecutionPointerData],
    ) -> WorkflowResult<()>;

    /// Create a single execution pointer
    async fn create_execution_pointer(&self, pointer: &ExecutionPointerData) -> WorkflowResult<()>;

    /// Update execution pointers
    async fn update_execution_pointers(&self, pointers: &[ExecutionPointerData]) -> WorkflowResult<()>;

    /// Update a single execution pointer
    async fn update_execution_pointer(&self, pointer: &ExecutionPointerData) -> WorkflowResult<()>;

    /// Get execution pointers for a workflow instance
    async fn get_execution_pointers(&self, workflow_id: Uuid) -> WorkflowResult<Vec<ExecutionPointerData>>;

    /// Get active execution pointers across all workflows
    async fn get_active_execution_pointers(&self) -> WorkflowResult<Vec<ExecutionPointerData>>;

    // Event operations
    
    /// Store an event
    async fn create_event(&self, event: &Event) -> WorkflowResult<()>;

    /// Get events by criteria
    async fn get_events(&self, filter: &EventFilter) -> WorkflowResult<Vec<Event>>;

    /// Mark events as processed
    async fn mark_events_processed(&self, event_ids: &[Uuid]) -> WorkflowResult<()>;

    /// Clean up old events
    async fn purge_events(&self, older_than: DateTime<Utc>) -> WorkflowResult<u64>;

    // Event subscription operations
    
    /// Create an event subscription
    async fn create_subscription(&self, subscription: &EventSubscription) -> WorkflowResult<()>;

    /// Get subscriptions for an event
    async fn get_subscriptions_for_event(
        &self,
        event_name: &str,
        event_key: Option<&str>,
    ) -> WorkflowResult<Vec<EventSubscription>>;

    /// Remove a subscription
    async fn remove_subscription(&self, subscription_id: Uuid) -> WorkflowResult<()>;

    /// Clean up inactive subscriptions
    async fn purge_subscriptions(&self, older_than: DateTime<Utc>) -> WorkflowResult<u64>;

    // Execution history operations
    
    /// Record an execution history entry
    async fn create_execution_history(&self, entry: &ExecutionHistoryData) -> WorkflowResult<()>;

    /// Get execution history for a workflow
    async fn get_execution_history(&self, workflow_id: Uuid) -> WorkflowResult<Vec<ExecutionHistoryData>>;

    /// Get execution history with filtering
    async fn get_execution_history_filtered(
        &self,
        filter: &ExecutionHistoryFilter,
    ) -> WorkflowResult<Vec<ExecutionHistoryData>>;

    // Error logging operations
    
    /// Record workflow execution errors
    async fn create_execution_error(&self, error: &ExecutionErrorData) -> WorkflowResult<()>;

    /// Get errors for a workflow instance
    async fn get_execution_errors(&self, workflow_id: Uuid) -> WorkflowResult<Vec<ExecutionErrorData>>;

    // Statistics and metrics operations
    
    /// Get workflow execution statistics
    async fn get_workflow_stats(&self) -> WorkflowResult<WorkflowStatistics>;

    /// Get step execution statistics
    async fn get_step_stats(&self, step_name: Option<&str>) -> WorkflowResult<Vec<StepStatistics>>;

    // Maintenance operations
    
    /// Purge completed workflows older than specified date
    async fn purge_workflows(&self, older_than: DateTime<Utc>) -> WorkflowResult<u64>;

    /// Optimize database performance (vacuum, reindex, etc.)
    async fn optimize(&self) -> WorkflowResult<()>;

    /// Get storage usage statistics
    async fn get_storage_stats(&self) -> WorkflowResult<StorageStatistics>;
}

/// Workflow instance data for persistence
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct WorkflowInstanceData {
    pub id: Uuid,
    pub workflow_definition_id: String,
    pub version: i32,
    pub description: Option<String>,
    pub reference: Option<String>,
    pub status: WorkflowInstanceStatus,
    pub data: Option<serde_json::Value>,
    pub create_time: DateTime<Utc>,
    pub complete_time: Option<DateTime<Utc>>,
    pub next_execution: Option<DateTime<Utc>>,
    pub node_id: Option<String>, // For distributed execution
    pub correlation_id: Option<String>,
    pub tags: HashMap<String, String>,
}

/// Workflow instance status for persistence
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum WorkflowInstanceStatus {
    Runnable = 0,
    Suspended = 1,
    Complete = 2,
    Terminated = 3,
}

/// Execution pointer data for persistence
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionPointerData {
    pub id: Uuid,
    pub workflow_instance_id: Uuid,
    pub step_id: i32,
    pub step_name: String,
    pub active: bool,
    pub sleep_until: Option<DateTime<Utc>>,
    pub persistence_data: Option<serde_json::Value>,
    pub start_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
    pub event_name: Option<String>,
    pub event_key: Option<String>,
    pub event_published: bool,
    pub event_data: Option<serde_json::Value>,
    pub retry_count: i32,
    pub children: Vec<Uuid>,
    pub context_item: Option<serde_json::Value>,
    pub predecessor_id: Option<Uuid>,
    pub outcome: Option<serde_json::Value>,
    pub status: ExecutionPointerStatus,
    pub scope: Vec<String>,
}

/// Execution pointer status for persistence
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum ExecutionPointerStatus {
    Runnable = 0,
    Pending = 1,
    Running = 2,
    Complete = 3,
    Sleeping = 4,
    WaitingForEvent = 5,
    WaitingForChildren = 6,
    Failed = 7,
    Compensated = 8,
    Cancelled = 9,
    PendingPredecessor = 10,
}

/// Execution history data for persistence
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionHistoryData {
    pub id: Uuid,
    pub workflow_instance_id: Uuid,
    pub step_id: i32,
    pub step_name: String,
    pub execution_pointer_id: Uuid,
    pub event_type: ExecutionEventType,
    pub event_time: DateTime<Utc>,
    pub details: Option<serde_json::Value>,
    pub correlation_id: String,
    pub duration_ms: Option<i64>,
}

/// Types of execution events for history
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum ExecutionEventType {
    StepStarted = 1,
    StepCompleted = 2,
    StepFailed = 3,
    StepRetried = 4,
    StepCompensated = 5,
    WorkflowStarted = 10,
    WorkflowCompleted = 11,
    WorkflowSuspended = 12,
    WorkflowResumed = 13,
    WorkflowTerminated = 14,
    EventPublished = 20,
    EventReceived = 21,
}

/// Execution error data for persistence
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionErrorData {
    pub id: Uuid,
    pub workflow_instance_id: Uuid,
    pub execution_pointer_id: Option<Uuid>,
    pub step_id: Option<i32>,
    pub step_name: Option<String>,
    pub error_time: DateTime<Utc>,
    pub error_type: String,
    pub error_message: String,
    pub error_details: Option<serde_json::Value>,
    pub retry_count: i32,
    pub correlation_id: Option<String>,
    pub resolved: bool,
}

/// Filter for querying workflow instances
#[derive(Debug, Clone, Default)]
pub struct WorkflowInstanceFilter {
    pub workflow_definition_id: Option<String>,
    pub status: Option<WorkflowInstanceStatus>,
    pub created_after: Option<DateTime<Utc>>,
    pub created_before: Option<DateTime<Utc>>,
    pub updated_after: Option<DateTime<Utc>>,
    pub updated_before: Option<DateTime<Utc>>,
    pub node_id: Option<String>,
    pub tags: Option<HashMap<String, String>>,
    pub limit: Option<u32>,
    pub offset: Option<u32>,
}

/// Filter for querying events
#[derive(Debug, Clone, Default)]
pub struct EventFilter {
    pub event_name: Option<String>,
    pub event_key: Option<String>,
    pub processed: Option<bool>,
    pub created_after: Option<DateTime<Utc>>,
    pub created_before: Option<DateTime<Utc>>,
    pub limit: Option<u32>,
    pub offset: Option<u32>,
}

/// Filter for querying execution history
#[derive(Debug, Clone, Default)]
pub struct ExecutionHistoryFilter {
    pub workflow_instance_id: Option<Uuid>,
    pub step_name: Option<String>,
    pub event_type: Option<ExecutionEventType>,
    pub after: Option<DateTime<Utc>>,
    pub before: Option<DateTime<Utc>>,
    pub limit: Option<u32>,
    pub offset: Option<u32>,
}

/// Workflow execution statistics
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct WorkflowStatistics {
    pub total_workflows: u64,
    pub running_workflows: u64,
    pub completed_workflows: u64,
    pub failed_workflows: u64,
    pub suspended_workflows: u64,
    pub average_execution_time_ms: Option<f64>,
    pub workflows_started_today: u64,
    pub workflows_completed_today: u64,
    pub error_rate_percentage: f64,
    pub throughput_per_hour: f64,
}

/// Step execution statistics
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct StepStatistics {
    pub step_name: String,
    pub total_executions: u64,
    pub successful_executions: u64,
    pub failed_executions: u64,
    pub average_duration_ms: Option<f64>,
    pub retry_rate_percentage: f64,
    pub last_executed: Option<DateTime<Utc>>,
}

/// Storage usage statistics
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct StorageStatistics {
    pub total_size_bytes: u64,
    pub workflow_instances_count: u64,
    pub execution_pointers_count: u64,
    pub events_count: u64,
    pub subscriptions_count: u64,
    pub execution_history_count: u64,
    pub execution_errors_count: u64,
    pub oldest_workflow: Option<DateTime<Utc>>,
    pub newest_workflow: Option<DateTime<Utc>>,
}

/// PostgreSQL-specific implementation interface (for f2)
#[async_trait]
pub trait PostgresPersistenceProvider: PersistenceProvider {
    /// Get the connection pool
    fn get_pool(&self) -> &sqlx::PgPool;

    /// Run database migrations
    async fn migrate(&self) -> WorkflowResult<()>;

    /// Create database indexes for optimal performance
    async fn create_indexes(&self) -> WorkflowResult<()>;

    /// Analyze query performance
    async fn analyze_performance(&self) -> WorkflowResult<PerformanceAnalysis>;

    /// Execute custom SQL query (for advanced use cases)
    async fn execute_query(&self, sql: &str, params: &[&dyn sqlx::Encode<'_, sqlx::Postgres>]) -> WorkflowResult<sqlx::postgres::PgQueryResult>;

    /// Get connection pool statistics
    async fn get_pool_stats(&self) -> WorkflowResult<PoolStatistics>;
}

/// Database performance analysis
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct PerformanceAnalysis {
    pub slow_queries: Vec<SlowQuery>,
    pub index_usage: Vec<IndexUsage>,
    pub table_sizes: Vec<TableSize>,
    pub connection_stats: PoolStatistics,
}

/// Slow query information
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct SlowQuery {
    pub query: String,
    pub avg_duration_ms: f64,
    pub call_count: u64,
    pub total_time_ms: f64,
}

/// Index usage statistics
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct IndexUsage {
    pub table_name: String,
    pub index_name: String,
    pub index_scans: u64,
    pub tuples_read: u64,
    pub tuples_fetched: u64,
}

/// Table size information
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct TableSize {
    pub table_name: String,
    pub size_bytes: u64,
    pub row_count: u64,
    pub last_vacuum: Option<DateTime<Utc>>,
    pub last_analyze: Option<DateTime<Utc>>,
}

/// Connection pool statistics
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct PoolStatistics {
    pub total_connections: u32,
    pub active_connections: u32,
    pub idle_connections: u32,
    pub waiting_connections: u32,
    pub max_connections: u32,
    pub connection_timeout_ms: u64,
    pub idle_timeout_ms: u64,
}

/// Transaction context for atomic operations
#[async_trait]
pub trait TransactionContext: Send + Sync {
    /// Commit the transaction
    async fn commit(self: Box<Self>) -> WorkflowResult<()>;

    /// Rollback the transaction
    async fn rollback(self: Box<Self>) -> WorkflowResult<()>;

    /// Create a workflow instance within this transaction
    async fn create_workflow_instance(&mut self, instance: &WorkflowInstanceData) -> WorkflowResult<()>;

    /// Update a workflow instance within this transaction
    async fn update_workflow_instance(&mut self, instance: &WorkflowInstanceData) -> WorkflowResult<()>;

    /// Create execution pointers within this transaction
    async fn create_execution_pointers(
        &mut self,
        workflow_id: Uuid,
        pointers: &[ExecutionPointerData],
    ) -> WorkflowResult<()>;

    /// Update execution pointers within this transaction
    async fn update_execution_pointers(&mut self, pointers: &[ExecutionPointerData]) -> WorkflowResult<()>;

    /// Create execution history within this transaction
    async fn create_execution_history(&mut self, entry: &ExecutionHistoryData) -> WorkflowResult<()>;
}

/// Extended persistence provider with transaction support
#[async_trait]
pub trait TransactionalPersistenceProvider: PersistenceProvider {
    /// Begin a new transaction
    async fn begin_transaction(&self) -> WorkflowResult<Box<dyn TransactionContext>>;

    /// Execute multiple operations atomically
    async fn execute_transaction<F, T>(&self, operation: F) -> WorkflowResult<T>
    where
        F: for<'a> FnOnce(&'a mut dyn TransactionContext) -> std::pin::Pin<Box<dyn std::future::Future<Output = WorkflowResult<T>> + Send + 'a>> + Send,
        T: Send;
}



#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_workflow_instance_data_serialization() {
        let instance = WorkflowInstanceData {
            id: Uuid::new_v4(),
            workflow_definition_id: "test_workflow".to_string(),
            version: 1,
            description: Some("Test description".to_string()),
            reference: None,
            status: WorkflowInstanceStatus::Runnable,
            data: Some(serde_json::json!({"test": "data"})),
            create_time: Utc::now(),
            complete_time: None,
            next_execution: None,
            node_id: None,
            correlation_id: Some("test-correlation".to_string()),
            tags: HashMap::new(),
        };

        let serialized = serde_json::to_string(&instance).unwrap();
        let deserialized: WorkflowInstanceData = serde_json::from_str(&serialized).unwrap();
        
        assert_eq!(instance.id, deserialized.id);
        assert_eq!(instance.workflow_definition_id, deserialized.workflow_definition_id);
        assert_eq!(instance.status, deserialized.status);
    }

    #[test]
    fn test_execution_pointer_status() {
        assert_eq!(ExecutionPointerStatus::Pending as i32, 1);
        assert_eq!(ExecutionPointerStatus::Running as i32, 2);
        assert_eq!(ExecutionPointerStatus::Complete as i32, 3);
    }

    #[test]
    fn test_workflow_instance_filter_default() {
        let filter = WorkflowInstanceFilter::default();
        assert!(filter.workflow_definition_id.is_none());
        assert!(filter.status.is_none());
        assert!(filter.limit.is_none());
    }

    #[test]
    fn test_storage_statistics() {
        let stats = StorageStatistics {
            total_size_bytes: 1024 * 1024 * 1024, // 1GB
            workflow_instances_count: 100,
            execution_pointers_count: 500,
            events_count: 1000,
            subscriptions_count: 50,
            execution_history_count: 2000,
            execution_errors_count: 25,
            oldest_workflow: Some(Utc::now() - chrono::Duration::days(30)),
            newest_workflow: Some(Utc::now()),
        };

        assert_eq!(stats.workflow_instances_count, 100);
        assert_eq!(stats.execution_errors_count, 25);
        assert_eq!(stats.total_size_bytes, 1024 * 1024 * 1024);
    }
}
