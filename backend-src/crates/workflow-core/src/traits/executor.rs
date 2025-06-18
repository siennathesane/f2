use async_trait::async_trait;
use uuid::Uuid;
use std::sync::Arc;
use crate::models::error::WorkflowResult;
use crate::traits::{StepBody, StepExecutionContext};
use crate::traits::persistence::{WorkflowInstanceData, ExecutionPointerData};
use crate::execution_result::ExecutionResult;
use crate::WorkflowDefinition;

/// Core workflow execution engine trait
/// 
/// The executor is responsible for running workflow instances, executing steps,
/// managing execution state, handling errors and retries, and coordinating
/// with the persistence layer.
#[async_trait]
pub trait WorkflowExecutor: Send + Sync {
    /// Execute a single workflow iteration
    /// 
    /// This processes all runnable execution pointers for a workflow instance,
    /// executing steps, updating state, and determining next actions.
    async fn execute_workflow(&self, instance: &mut WorkflowInstanceData) -> WorkflowResult<ExecutionSummary>;

    /// Execute a specific step
    async fn execute_step(
        &self,
        context: &StepExecutionContext,
        step_body: Arc<dyn StepBody>,
    ) -> WorkflowResult<ExecutionResult>;

    /// Process the result of step execution
    async fn process_execution_result(
        &self,
        instance: &mut WorkflowInstanceData,
        pointer: &mut ExecutionPointerData,
        result: ExecutionResult,
    ) -> WorkflowResult<Vec<ExecutionAction>>;

    /// Determine next execution time for a workflow instance
    async fn calculate_next_execution(&self, instance: &WorkflowInstanceData) -> WorkflowResult<Option<chrono::DateTime<chrono::Utc>>>;

    /// Check if a workflow instance is complete
    fn is_workflow_complete(&self, instance: &WorkflowInstanceData) -> bool;

    /// Handle workflow completion
    async fn complete_workflow(&self, instance: &mut WorkflowInstanceData) -> WorkflowResult<()>;

    /// Handle workflow failure
    async fn fail_workflow(&self, instance: &mut WorkflowInstanceData, error: &crate::models::error::WorkflowError) -> WorkflowResult<()>;

    /// Handle step retry logic
    async fn should_retry_step(
        &self,
        pointer: &ExecutionPointerData,
        error: &crate::models::error::WorkflowError,
    ) -> WorkflowResult<bool>;

    /// Calculate retry delay for a failed step
    fn calculate_retry_delay(&self, pointer: &ExecutionPointerData, error: &crate::models::error::WorkflowError) -> std::time::Duration;

    /// Get workflow definition for execution
    async fn get_workflow_definition(&self, workflow_id: &str, version: i32) -> WorkflowResult<Arc<WorkflowDefinition>>;

    /// Validate workflow instance before execution
    async fn validate_instance(&self, instance: &WorkflowInstanceData) -> WorkflowResult<()>;
}

/// Summary of workflow execution iteration
#[derive(Debug, Clone)]
pub struct ExecutionSummary {
    /// Workflow instance ID
    pub workflow_id: Uuid,
    
    /// Number of steps executed in this iteration
    pub steps_executed: u32,
    
    /// Number of steps that failed
    pub steps_failed: u32,
    
    /// Number of steps waiting for events
    pub steps_waiting: u32,
    
    /// Whether the workflow completed
    pub workflow_completed: bool,
    
    /// Whether the workflow failed
    pub workflow_failed: bool,
    
    /// Actions to be performed after execution
    pub actions: Vec<ExecutionAction>,
    
    /// Next execution time
    pub next_execution: Option<chrono::DateTime<chrono::Utc>>,
    
    /// Execution duration
    pub duration: std::time::Duration,
    
    /// Errors encountered during execution
    pub errors: Vec<crate::models::error::WorkflowError>,
}

/// Actions to be performed after step execution
#[derive(Debug, Clone)]
pub enum ExecutionAction {
    /// Persist workflow instance data
    PersistInstance(WorkflowInstanceData),
    
    /// Persist execution pointer data
    PersistPointers(Vec<ExecutionPointerData>),
    
    /// Schedule workflow for future execution
    ScheduleExecution {
        workflow_id: Uuid,
        execute_at: chrono::DateTime<chrono::Utc>,
    },
    
    /// Schedule a specific step for execution
    ScheduleStep {
        pointer_id: Uuid,
        step_id: i32,
        execute_time: chrono::DateTime<chrono::Utc>,
    },
    
    /// Create event subscription
    CreateSubscription {
        workflow_id: Uuid,
        pointer_id: Uuid,
        event_name: String,
        event_key: Option<String>,
    },
    
    /// Create event subscription (alternative format)
    CreateEventSubscription {
        subscription_id: Uuid,
        event_name: String,
        event_key: Option<String>,
    },
    
    /// Remove event subscription
    RemoveSubscription {
        subscription_id: Uuid,
    },
    
    /// Log execution history
    LogHistory {
        workflow_id: Uuid,
        step_id: i32,
        step_name: String,
        event_type: crate::traits::persistence::ExecutionEventType,
        details: Option<serde_json::Value>,
        duration: Option<std::time::Duration>,
    },
    
    /// Log execution error
    LogError {
        workflow_id: Uuid,
        pointer_id: Option<Uuid>,
        step_id: Option<i32>,
        error: crate::models::error::WorkflowError,
    },
    
    /// Trigger compensation workflow
    TriggerCompensation {
        workflow_id: Uuid,
        failed_step_id: i32,
    },
    
    /// Send notification
    SendNotification {
        workflow_id: Uuid,
        notification_type: NotificationType,
        details: serde_json::Value,
    },
    
    /// Call external service (gRPC)
    CallService {
        service_name: String,
        operation: String,
        payload: serde_json::Value,
        correlation_id: String,
    },
}

/// Types of notifications
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub enum NotificationType {
    WorkflowStarted,
    WorkflowCompleted,
    WorkflowFailed,
    StepFailed,
    ManualInterventionRequired,
    CompensationTriggered,
}

/// Step execution strategy
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExecutionStrategy {
    /// Execute steps sequentially
    Sequential,
    /// Execute steps in parallel where possible
    Parallel,
    /// Execute steps with maximum concurrency
    MaxConcurrency,
}

/// Execution context for the workflow executor
#[derive(Debug, Clone)]
pub struct ExecutionContext {
    /// Current execution strategy
    pub strategy: ExecutionStrategy,
    
    /// Maximum number of concurrent step executions
    pub max_concurrency: u32,
    
    /// Timeout for individual step execution
    pub step_timeout: std::time::Duration,
    
    /// Maximum total workflow execution time
    pub workflow_timeout: std::time::Duration,
    
    /// Enable compensation on failure
    pub enable_compensation: bool,
    
    /// Correlation ID for tracing
    pub correlation_id: String,
    
    /// Node ID for distributed execution
    pub node_id: Option<String>,
}

impl Default for ExecutionContext {
    fn default() -> Self {
        Self {
            strategy: ExecutionStrategy::Sequential,
            max_concurrency: 10,
            step_timeout: std::time::Duration::from_secs(300), // 5 minutes
            workflow_timeout: std::time::Duration::from_secs(3600), // 1 hour
            enable_compensation: true,
            correlation_id: uuid::Uuid::new_v4().to_string(),
            node_id: None,
        }
    }
}

/// Circuit breaker for failing services
#[derive(Debug, Clone)]
pub struct CircuitBreaker {
    /// Service name
    pub service_name: String,
    
    /// Current state of the circuit breaker
    pub state: CircuitBreakerState,
    
    /// Failure threshold before opening circuit
    pub failure_threshold: u32,
    
    /// Current failure count
    pub failure_count: u32,
    
    /// Timeout before attempting to close circuit
    pub timeout: std::time::Duration,
    
    /// Time when circuit was opened
    pub opened_at: Option<chrono::DateTime<chrono::Utc>>,
}

/// Circuit breaker states
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CircuitBreakerState {
    Closed,    // Normal operation
    Open,      // Failing, reject calls
    HalfOpen,  // Testing if service recovered
}

impl CircuitBreaker {
    pub fn new(service_name: String, failure_threshold: u32, timeout: std::time::Duration) -> Self {
        Self {
            service_name,
            state: CircuitBreakerState::Closed,
            failure_threshold,
            failure_count: 0,
            timeout,
            opened_at: None,
        }
    }

    /// Record a successful operation
    pub fn record_success(&mut self) {
        self.failure_count = 0;
        self.state = CircuitBreakerState::Closed;
        self.opened_at = None;
    }

    /// Record a failed operation
    pub fn record_failure(&mut self) {
        self.failure_count += 1;
        if self.failure_count >= self.failure_threshold {
            self.state = CircuitBreakerState::Open;
            self.opened_at = Some(chrono::Utc::now());
        }
    }

    /// Check if the circuit breaker allows execution
    pub fn can_execute(&mut self) -> bool {
        match self.state {
            CircuitBreakerState::Closed => true,
            CircuitBreakerState::Open => {
                if let Some(opened_at) = self.opened_at {
                    let elapsed = chrono::Utc::now().signed_duration_since(opened_at);
                    if elapsed.to_std().unwrap_or_default() >= self.timeout {
                        self.state = CircuitBreakerState::HalfOpen;
                        true
                    } else {
                        false
                    }
                } else {
                    false
                }
            }
            CircuitBreakerState::HalfOpen => true,
        }
    }
}

/// Execution statistics tracking
#[derive(Debug, Clone, Default)]
pub struct ExecutionStatistics {
    /// Total steps executed
    pub total_steps: u64,
    
    /// Successful step executions
    pub successful_steps: u64,
    
    /// Failed step executions
    pub failed_steps: u64,
    
    /// Retried step executions
    pub retried_steps: u64,
    
    /// Total execution time
    pub total_execution_time: std::time::Duration,
    
    /// Average step execution time
    pub average_step_time: std::time::Duration,
    
    /// Circuit breakers by service
    pub circuit_breakers: std::collections::HashMap<String, CircuitBreaker>,
}

impl ExecutionStatistics {
    /// Record a successful step execution
    pub fn record_success(&mut self, duration: std::time::Duration) {
        self.total_steps += 1;
        self.successful_steps += 1;
        self.total_execution_time += duration;
        self.update_average();
    }

    /// Record a failed step execution
    pub fn record_failure(&mut self, duration: std::time::Duration) {
        self.total_steps += 1;
        self.failed_steps += 1;
        self.total_execution_time += duration;
        self.update_average();
    }

    /// Record a retried step execution
    pub fn record_retry(&mut self) {
        self.retried_steps += 1;
    }

    /// Update average execution time
    fn update_average(&mut self) {
        if self.total_steps > 0 {
            self.average_step_time = self.total_execution_time / self.total_steps as u32;
        }
    }

    /// Get or create circuit breaker for a service
    pub fn get_circuit_breaker(&mut self, service_name: &str) -> &mut CircuitBreaker {
        self.circuit_breakers.entry(service_name.to_string()).or_insert_with(|| {
            CircuitBreaker::new(
                service_name.to_string(),
                5, // 5 failures before opening
                std::time::Duration::from_secs(60), // 1 minute timeout
            )
        })
    }

    /// Calculate error rate percentage
    pub fn error_rate(&self) -> f64 {
        if self.total_steps == 0 {
            0.0
        } else {
            (self.failed_steps as f64 / self.total_steps as f64) * 100.0
        }
    }

    /// Calculate retry rate percentage
    pub fn retry_rate(&self) -> f64 {
        if self.total_steps == 0 {
            0.0
        } else {
            (self.retried_steps as f64 / self.total_steps as f64) * 100.0
        }
    }
}

/// Distributed execution coordinator
#[async_trait]
pub trait DistributedExecutionCoordinator: Send + Sync {
    /// Acquire lock for workflow execution
    async fn acquire_workflow_lock(&self, workflow_id: Uuid, node_id: &str) -> WorkflowResult<Option<String>>;

    /// Release workflow execution lock
    async fn release_workflow_lock(&self, workflow_id: Uuid, lock_token: &str) -> WorkflowResult<()>;

    /// Register this node as available for execution
    async fn register_node(&self, node_id: &str, capabilities: &[String]) -> WorkflowResult<()>;

    /// Unregister this node
    async fn unregister_node(&self, node_id: &str) -> WorkflowResult<()>;

    /// Get list of available nodes
    async fn get_available_nodes(&self) -> WorkflowResult<Vec<NodeInfo>>;

    /// Heartbeat to indicate node is alive
    async fn heartbeat(&self, node_id: &str) -> WorkflowResult<()>;
}

/// Information about an execution node
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct NodeInfo {
    pub node_id: String,
    pub last_heartbeat: chrono::DateTime<chrono::Utc>,
    pub capabilities: Vec<String>,
    pub active_workflows: u32,
    pub load_average: f64,
}

/// gRPC service integration helpers
pub mod grpc_support {
    use super::*;
    use tonic::{Request, Response, Status};

    /// Helper trait for steps that make gRPC calls
    #[async_trait]
    pub trait GrpcStepBody: StepBody {
        /// gRPC client type
        type Client: Send + Sync + Clone;

        /// Get or create gRPC client
        async fn get_client(&self) -> WorkflowResult<Self::Client>;

        /// Make gRPC call with timeout and circuit breaker
        async fn call_service<F, T>(&self, operation: F) -> WorkflowResult<T>
        where
            F: std::future::Future<Output = Result<Response<T>, Status>> + Send,
            T: Send,
        {
            let timeout = std::time::Duration::from_secs(30);
            
            tokio::time::timeout(timeout, operation)
                .await
                .map_err(|_| crate::models::error::WorkflowError::GrpcServiceError {
                    service: std::any::type_name::<Self::Client>().to_string(),
                    message: "Request timeout".to_string(),
                })?
                .map(|response| response.into_inner())
                .map_err(|status| crate::models::error::WorkflowError::GrpcServiceError {
                    service: std::any::type_name::<Self::Client>().to_string(),
                    message: status.message().to_string(),
                })
        }

        /// Service health check
        async fn health_check(&self) -> WorkflowResult<bool> {
            // Default implementation - override for actual health checks
            Ok(true)
        }
    }

    /// Configuration for gRPC services
    #[derive(Debug, Clone)]
    pub struct GrpcConfig {
        pub endpoint: String,
        pub timeout: std::time::Duration,
        pub max_retries: u32,
        pub retry_delay: std::time::Duration,
        pub enable_tls: bool,
        pub compression: Option<tonic::codec::CompressionEncoding>,
    }

    impl Default for GrpcConfig {
        fn default() -> Self {
            Self {
                endpoint: "http://localhost:50051".to_string(),
                timeout: std::time::Duration::from_secs(30),
                max_retries: 3,
                retry_delay: std::time::Duration::from_millis(500),
                enable_tls: false,
                compression: None,
            }
        }
    }

    /// gRPC service registry for managing multiple services
    #[derive(Debug, Default)]
    pub struct GrpcServiceRegistry {
        services: std::collections::HashMap<String, GrpcConfig>,
    }

    impl GrpcServiceRegistry {
        pub fn new() -> Self {
            Self::default()
        }

        pub fn register_service(&mut self, name: String, config: GrpcConfig) {
            self.services.insert(name, config);
        }

        pub fn get_service_config(&self, name: &str) -> Option<&GrpcConfig> {
            self.services.get(name)
        }

        pub fn remove_service(&mut self, name: &str) -> Option<GrpcConfig> {
            self.services.remove(name)
        }

        pub fn list_services(&self) -> Vec<&String> {
            self.services.keys().collect()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_execution_summary_creation() {
        let summary = ExecutionSummary {
            workflow_id: Uuid::new_v4(),
            steps_executed: 5,
            steps_failed: 1,
            steps_waiting: 2,
            workflow_completed: false,
            workflow_failed: false,
            actions: vec![],
            next_execution: Some(chrono::Utc::now()),
            duration: std::time::Duration::from_secs(10),
            errors: vec![],
        };

        assert_eq!(summary.steps_executed, 5);
        assert_eq!(summary.steps_failed, 1);
        assert!(!summary.workflow_completed);
    }

    #[test]
    fn test_execution_context_default() {
        let context = ExecutionContext::default();
        assert_eq!(context.strategy, ExecutionStrategy::Sequential);
        assert_eq!(context.max_concurrency, 10);
        assert!(context.enable_compensation);
    }

    #[test]
    fn test_circuit_breaker() {
        let mut cb = CircuitBreaker::new(
            "test_service".to_string(),
            3,
            std::time::Duration::from_secs(60),
        );

        // Should be closed initially
        assert!(cb.can_execute());
        assert_eq!(cb.state, CircuitBreakerState::Closed);

        // Record failures
        cb.record_failure();
        cb.record_failure();
        assert!(cb.can_execute()); // Still closed

        cb.record_failure();
        assert_eq!(cb.state, CircuitBreakerState::Open);
        assert!(!cb.can_execute()); // Now open

        // Record success should close it
        cb.record_success();
        assert_eq!(cb.state, CircuitBreakerState::Closed);
        assert!(cb.can_execute());
    }

    #[test]
    fn test_execution_statistics() {
        let mut stats = ExecutionStatistics::default();
        
        stats.record_success(std::time::Duration::from_millis(100));
        stats.record_success(std::time::Duration::from_millis(200));
        stats.record_failure(std::time::Duration::from_millis(50));

        assert_eq!(stats.total_steps, 3);
        assert_eq!(stats.successful_steps, 2);
        assert_eq!(stats.failed_steps, 1);
        assert_eq!(stats.error_rate(), 33.333333333333336);
    }

    #[test]
    fn test_grpc_config_default() {
        use grpc_support::GrpcConfig;
        
        let config = GrpcConfig::default();
        assert_eq!(config.endpoint, "http://localhost:50051");
        assert_eq!(config.timeout, std::time::Duration::from_secs(30));
        assert_eq!(config.max_retries, 3);
        assert!(!config.enable_tls);
    }

    #[test]
    fn test_grpc_service_registry() {
        use grpc_support::{GrpcServiceRegistry, GrpcConfig};
        
        let mut registry = GrpcServiceRegistry::new();
        let config = GrpcConfig::default();
        
        registry.register_service("test_service".to_string(), config);
        assert!(registry.get_service_config("test_service").is_some());
        assert_eq!(registry.list_services().len(), 1);
        
        registry.remove_service("test_service");
        assert!(registry.get_service_config("test_service").is_none());
    }
}
