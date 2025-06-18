use async_trait::async_trait;
use uuid::Uuid;
use crate::models::error::WorkflowResult;
use crate::traits::{Workflow, UntypedWorkflow};
use crate::event::{Event, EventSubscription};
use std::sync::Arc;
use crate::traits::persistence::ExecutionEventType;

/// Main interface for the workflow engine
/// 
/// The WorkflowHost is responsible for:
/// - Managing workflow lifecycle (start, stop, suspend, resume, terminate)
/// - Registering workflow definitions
/// - Processing events and triggering workflows
/// - Managing workflow instances and their state
/// - Coordinating with the persistence layer
#[async_trait]
pub trait WorkflowHost: Send + Sync {
    /// Start the workflow host and begin processing
    async fn start(&mut self) -> WorkflowResult<()>;

    /// Stop the workflow host and clean up resources
    async fn stop(&mut self) -> WorkflowResult<()>;

    /// Check if the host is currently running
    fn is_running(&self) -> bool;

    /// Register a workflow definition with the host
    async fn register_workflow<T>(&mut self, workflow: Arc<dyn Workflow<T>>) -> WorkflowResult<()>
    where
        T: Send + Sync + Clone + 'static;

    /// Register an untyped workflow definition
    async fn register_untyped_workflow(&mut self, workflow: Arc<dyn UntypedWorkflow>) -> WorkflowResult<()>;

    /// Start a new workflow instance
    async fn start_workflow<T>(
        &self,
        workflow_id: &str,
        version: Option<i32>,
        data: T,
    ) -> WorkflowResult<Uuid>
    where
        T: Send + Sync + Clone + 'static;

    /// Start a workflow with a specific instance ID (for resuming)
    async fn start_workflow_with_id<T>(
        &self,
        instance_id: Uuid,
        workflow_id: &str,
        version: Option<i32>,
        data: T,
    ) -> WorkflowResult<()>
    where
        T: Send + Sync + Clone + 'static;

    /// Suspend a running workflow instance
    async fn suspend_workflow(&self, instance_id: Uuid) -> WorkflowResult<()>;

    /// Resume a suspended workflow instance
    async fn resume_workflow(&self, instance_id: Uuid) -> WorkflowResult<()>;

    /// Terminate a workflow instance (cannot be resumed)
    async fn terminate_workflow(&self, instance_id: Uuid) -> WorkflowResult<()>;

    /// Publish an event to trigger waiting workflows
    async fn publish_event(&self, event: Event) -> WorkflowResult<()>;

    /// Subscribe to events for a workflow step
    async fn subscribe_event(
        &self,
        subscription: EventSubscription,
    ) -> WorkflowResult<()>;

    /// Get the status of a workflow instance
    async fn get_workflow_status(&self, instance_id: Uuid) -> WorkflowResult<WorkflowStatus>;

    /// Get all workflow instances (with optional filtering)
    async fn get_workflow_instances(
        &self,
        filter: Option<WorkflowFilter>,
    ) -> WorkflowResult<Vec<WorkflowInstanceSummary>>;

    /// Get detailed information about a specific workflow instance
    async fn get_workflow_instance(&self, instance_id: Uuid) -> WorkflowResult<WorkflowInstanceDetails>;

    /// Purge completed workflow instances older than the specified age
    async fn purge_workflows(&self, older_than: chrono::Duration) -> WorkflowResult<u64>;

    /// Get workflow execution metrics
    async fn get_metrics(&self) -> WorkflowResult<WorkflowMetrics>;

    /// Health check for the workflow host
    async fn health_check(&self) -> WorkflowResult<HealthStatus>;
}

/// Workflow instance status
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum WorkflowStatus {
    /// Workflow is actively running
    Runnable,
    /// Workflow is suspended (manually or due to error)
    Suspended,
    /// Workflow completed successfully
    Complete,
    /// Workflow was terminated (either manually or due to fatal error)
    Terminated,
    /// Workflow is waiting for an external event
    WaitingForEvent,
    /// Workflow is sleeping/delayed
    Sleeping,
}

/// Filter for querying workflow instances
#[derive(Debug, Clone)]
pub struct WorkflowFilter {
    pub workflow_id: Option<String>,
    pub status: Option<WorkflowStatus>,
    pub created_after: Option<chrono::DateTime<chrono::Utc>>,
    pub created_before: Option<chrono::DateTime<chrono::Utc>>,
    pub tags: Option<Vec<String>>,
    pub limit: Option<u32>,
    pub offset: Option<u32>,
}

impl Default for WorkflowFilter {
    fn default() -> Self {
        Self {
            workflow_id: None,
            status: None,
            created_after: None,
            created_before: None,
            tags: None,
            limit: Some(100),
            offset: Some(0),
        }
    }
}

/// Summary information about a workflow instance
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct WorkflowInstanceSummary {
    pub id: Uuid,
    pub workflow_definition_id: String,
    pub version: i32,
    pub status: WorkflowStatus,
    pub description: Option<String>,
    pub reference: Option<String>,
    pub create_time: chrono::DateTime<chrono::Utc>,
    pub complete_time: Option<chrono::DateTime<chrono::Utc>>,
    pub next_execution: Option<chrono::DateTime<chrono::Utc>>,
    pub current_step: Option<String>,
    pub tags: Vec<String>,
}

/// Detailed information about a workflow instance
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct WorkflowInstanceDetails {
    pub summary: WorkflowInstanceSummary,
    pub data: Option<serde_json::Value>,
    pub execution_pointers: Vec<ExecutionPointerDetails>,
    pub execution_history: Vec<ExecutionHistoryEntry>,
    pub errors: Vec<crate::models::error::WorkflowError>,
}

/// Details about an execution pointer
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionPointerDetails {
    pub id: Uuid,
    pub step_id: i32,
    pub step_name: String,
    pub status: PointerStatus,
    pub active: bool,
    pub start_time: Option<chrono::DateTime<chrono::Utc>>,
    pub end_time: Option<chrono::DateTime<chrono::Utc>>,
    pub sleep_until: Option<chrono::DateTime<chrono::Utc>>,
    pub retry_count: i32,
    pub event_name: Option<String>,
    pub event_key: Option<String>,
    pub outcome: Option<serde_json::Value>,
    pub scope: Vec<String>,
}

/// Execution pointer status
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum PointerStatus {
    Pending,
    Running,
    Complete,
    Sleeping,
    WaitingForEvent,
    Failed,
    Compensated,
    Cancelled,
}

/// Execution history entry
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionHistoryEntry {
    pub timestamp: chrono::DateTime<chrono::Utc>,
    pub step_id: i32,
    pub step_name: String,
    pub event_type: ExecutionEventType,
    pub details: Option<serde_json::Value>,
    pub correlation_id: String,
}

// ExecutionEventType is defined in persistence.rs

/// Workflow execution metrics
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct WorkflowMetrics {
    pub total_workflows: u64,
    pub running_workflows: u64,
    pub completed_workflows: u64,
    pub failed_workflows: u64,
    pub suspended_workflows: u64,
    pub average_execution_time: Option<std::time::Duration>,
    pub step_metrics: Vec<StepMetrics>,
    pub error_rate: f64,
    pub throughput_per_minute: f64,
}

/// Metrics for individual steps
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct StepMetrics {
    pub step_name: String,
    pub total_executions: u64,
    pub successful_executions: u64,
    pub failed_executions: u64,
    pub average_duration: Option<std::time::Duration>,
    pub retry_rate: f64,
}

/// Health status of the workflow host
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct HealthStatus {
    pub status: HealthState,
    pub message: Option<String>,
    pub uptime: std::time::Duration,
    pub memory_usage: Option<u64>,
    pub active_workflows: u64,
    pub pending_events: u64,
    pub database_healthy: bool,
    pub services_healthy: Vec<ServiceHealth>,
}

/// Overall health state
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum HealthState {
    Healthy,
    Degraded,
    Unhealthy,
}

/// Health status of individual services
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ServiceHealth {
    pub service_name: String,
    pub healthy: bool,
    pub last_check: chrono::DateTime<chrono::Utc>,
    pub response_time: Option<std::time::Duration>,
    pub error_message: Option<String>,
}

/// Configuration for the workflow host
#[derive(Debug, Clone)]
pub struct WorkflowHostConfig {
    /// Maximum number of concurrent workflow executions
    pub max_concurrent_workflows: u32,
    
    /// Polling interval for checking runnable workflows
    pub polling_interval: std::time::Duration,
    
    /// Maximum time a workflow can run before being considered stuck
    pub max_workflow_execution_time: std::time::Duration,
    
    /// How often to persist workflow state
    pub persistence_interval: std::time::Duration,
    
    /// Maximum number of retry attempts for failed steps
    pub default_max_retries: u32,
    
    /// Default retry delay
    pub default_retry_delay: std::time::Duration,
    
    /// How long to keep completed workflows before purging
    pub completed_workflow_retention: chrono::Duration,
    
    /// Enable distributed execution coordination
    pub enable_distributed_mode: bool,
    
    /// Node ID for distributed mode
    pub node_id: Option<String>,
    
    /// Health check interval
    pub health_check_interval: std::time::Duration,
}

impl Default for WorkflowHostConfig {
    fn default() -> Self {
        Self {
            max_concurrent_workflows: 100,
            polling_interval: std::time::Duration::from_secs(5),
            max_workflow_execution_time: std::time::Duration::from_secs(3600), // 1 hour
            persistence_interval: std::time::Duration::from_secs(30),
            default_max_retries: 3,
            default_retry_delay: std::time::Duration::from_secs(1),
            completed_workflow_retention: chrono::Duration::days(30),
            enable_distributed_mode: false,
            node_id: None,
            health_check_interval: std::time::Duration::from_secs(30),
        }
    }
}

/// Event handler trait for workflow lifecycle events
#[async_trait]
pub trait WorkflowEventHandler: Send + Sync {
    async fn on_workflow_started(&self, instance_id: Uuid, workflow_id: &str) -> WorkflowResult<()>;
    async fn on_workflow_completed(&self, instance_id: Uuid, workflow_id: &str) -> WorkflowResult<()>;
    async fn on_workflow_failed(&self, instance_id: Uuid, workflow_id: &str, error: &crate::models::error::WorkflowError) -> WorkflowResult<()>;
    async fn on_step_started(&self, instance_id: Uuid, step_name: &str) -> WorkflowResult<()>;
    async fn on_step_completed(&self, instance_id: Uuid, step_name: &str) -> WorkflowResult<()>;
    async fn on_step_failed(&self, instance_id: Uuid, step_name: &str, error: &crate::models::error::WorkflowError) -> WorkflowResult<()>;
}



#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_workflow_status_serialization() {
        let status = WorkflowStatus::Runnable;
        let serialized = serde_json::to_string(&status).unwrap();
        let deserialized: WorkflowStatus = serde_json::from_str(&serialized).unwrap();
        assert_eq!(status, deserialized);
    }

    #[test]
    fn test_workflow_filter_default() {
        let filter = WorkflowFilter::default();
        assert_eq!(filter.limit, Some(100));
        assert_eq!(filter.offset, Some(0));
        assert!(filter.workflow_id.is_none());
    }

    #[test]
    fn test_workflow_host_config_default() {
        let config = WorkflowHostConfig::default();
        assert_eq!(config.max_concurrent_workflows, 100);
        assert_eq!(config.polling_interval, std::time::Duration::from_secs(5));
        assert!(!config.enable_distributed_mode);
    }

    #[test]
    fn test_health_status_creation() {
        let health = HealthStatus {
            status: HealthState::Healthy,
            message: Some("All systems operational".to_string()),
            uptime: std::time::Duration::from_secs(3600),
            memory_usage: Some(1024 * 1024 * 100), // 100MB
            active_workflows: 42,
            pending_events: 5,
            database_healthy: true,
            services_healthy: vec![
                ServiceHealth {
                    service_name: "face_detection".to_string(),
                    healthy: true,
                    last_check: chrono::Utc::now(),
                    response_time: Some(std::time::Duration::from_millis(50)),
                    error_message: None,
                }
            ],
        };

        assert_eq!(health.status, HealthState::Healthy);
        assert_eq!(health.active_workflows, 42);
        assert_eq!(health.services_healthy.len(), 1);
    }
}
