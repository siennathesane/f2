use sqlx::Row;
use uuid::Uuid;

/// Comprehensive error types for the workflow engine
#[derive(thiserror::Error, Clone, Debug, serde::Serialize, serde::Deserialize)]
pub enum WorkflowError {
    #[error("Workflow definition not found: {id}")]
    WorkflowDefinitionNotFound { id: String },

    #[error("Workflow instance not found: {id}")]
    WorkflowInstanceNotFound { id: Uuid },

    #[error("Invalid workflow definition: {reason}")]
    InvalidWorkflowDefinition { reason: String },

    #[error("Step execution failed: {step_name}: {reason}")]
    StepExecutionFailed { step_name: String, reason: String },

    #[error("Step not found: {step_id} in workflow: {workflow_id}")]
    StepNotFound { step_id: i32, workflow_id: String },

    #[error("Execution error: {reason}")]
    ExecutionError { reason: String },

    #[error("Persistence error: {0}")]
    PersistenceError(String),

    #[error("Serialization error: {0}")]
    SerializationError(String),

    #[error("Workflow is in invalid state: {state} for operation: {operation}")]
    InvalidWorkflowState { state: String, operation: String },

    #[error("Event subscription failed: {event_name}")]
    EventSubscriptionFailed { event_name: String },

    #[error("Workflow timeout: {timeout_seconds}s")]
    WorkflowTimeout { timeout_seconds: u64 },

    #[error("Compensation failed for step: {step_name}")]
    CompensationFailed { step_name: String },

    #[error("gRPC service error: {service}: {message}")]
    GrpcServiceError { service: String, message: String },

    #[error("Configuration error: {0}")]
    ConfigurationError(String),

    #[error("Authentication error: {0}")]
    AuthenticationError(String),

    #[error("Authorization error: user lacks permission for: {operation}")]
    AuthorizationError { operation: String },

    #[error("Resource not found: {0}")]
    NotFoundError(String),

    #[error("Validation error: {0}")]
    ValidationError(String),

    #[error("Internal error: {0}")]
    InternalError(String),
}

/// Result type alias for workflow operations
pub type WorkflowResult<T> = Result<T, WorkflowError>;

/// Error context for step execution failures
#[derive(Debug, Clone)]
pub struct StepErrorContext {
    pub workflow_id: Uuid,
    pub step_id: i32,
    pub step_name: String,
    pub retry_count: i32,
    pub error_time: chrono::DateTime<chrono::Utc>,
    pub error_message: String,
}

/// Classification of errors for retry logic
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ErrorClass {
    /// Temporary errors that should be retried (network timeouts, etc.)
    Transient,
    /// Errors that can be retried with potential success (rate limits, etc.)
    Retryable,
    /// Permanent errors that won't succeed on retry (validation errors, etc.)
    Permanent,
    /// Fatal errors that should terminate the workflow (security violations, etc.)
    Fatal,
}

impl WorkflowError {
    /// Classify error for retry logic (used in GitHub issue #6)
    pub fn classify(&self) -> ErrorClass {
        match self {
            WorkflowError::PersistenceError(msg) if msg.contains("PoolTimedOut") => ErrorClass::Transient,
            WorkflowError::PersistenceError(msg) if msg.contains("Io") => ErrorClass::Transient,
            WorkflowError::WorkflowTimeout { .. } => ErrorClass::Retryable,
            WorkflowError::EventSubscriptionFailed { .. } => ErrorClass::Retryable,
            WorkflowError::InvalidWorkflowDefinition { .. } => ErrorClass::Permanent,
            WorkflowError::WorkflowDefinitionNotFound { .. } => ErrorClass::Permanent,
            WorkflowError::InvalidWorkflowState { .. } => ErrorClass::Permanent,
            WorkflowError::AuthenticationError(_) => ErrorClass::Fatal,
            WorkflowError::AuthorizationError { .. } => ErrorClass::Fatal,
            WorkflowError::ConfigurationError(_) => ErrorClass::Fatal,
            WorkflowError::NotFoundError(_) => ErrorClass::Permanent,
            WorkflowError::ValidationError(_) => ErrorClass::Permanent,
            _ => ErrorClass::Permanent,
        }
    }

    /// Check if error should be retried based on classification
    pub fn should_retry(&self) -> bool {
        matches!(
            self.classify(),
            ErrorClass::Transient | ErrorClass::Retryable
        )
    }

    /// Get suggested retry delay based on error type
    pub fn retry_delay(&self) -> std::time::Duration {
        match self.classify() {
            ErrorClass::Transient => std::time::Duration::from_millis(100),
            ErrorClass::Retryable => std::time::Duration::from_secs(1),
            _ => std::time::Duration::from_secs(0),
        }
    }
}

// Additional From implementations for common conversion patterns
impl From<sqlx::Error> for WorkflowError {
    fn from(err: sqlx::Error) -> Self {
        WorkflowError::PersistenceError(err.to_string())
    }
}

impl From<serde_json::Error> for WorkflowError {
    fn from(err: serde_json::Error) -> Self {
        WorkflowError::SerializationError(err.to_string())
    }
}

impl From<anyhow::Error> for WorkflowError {
    fn from(err: anyhow::Error) -> Self {
        WorkflowError::InternalError(err.to_string())
    }
}

impl From<chrono::OutOfRangeError> for WorkflowError {
    fn from(err: chrono::OutOfRangeError) -> Self {
        WorkflowError::InternalError(format!("Date/time out of range: {}", err))
    }
}

impl From<sqlx::migrate::MigrateError> for WorkflowError {
    fn from(err: sqlx::migrate::MigrateError) -> Self {
        WorkflowError::PersistenceError(format!("Migration error: {}", err))
    }
}

// Helper trait for converting sqlx Row errors
pub trait SqlxRowExt {
    fn try_get_uuid(&self, column: &str) -> WorkflowResult<Uuid>;
    fn try_get_i32(&self, column: &str) -> WorkflowResult<i32>;
    fn try_get_i64(&self, column: &str) -> WorkflowResult<i64>;
    fn try_get_string(&self, column: &str) -> WorkflowResult<String>;
    fn try_get_optional_string(&self, column: &str) -> WorkflowResult<Option<String>>;
    fn try_get_json(&self, column: &str) -> WorkflowResult<Option<serde_json::Value>>;
    fn try_get_datetime(&self, column: &str) -> WorkflowResult<chrono::DateTime<chrono::Utc>>;
    fn try_get_optional_datetime(&self, column: &str) -> WorkflowResult<Option<chrono::DateTime<chrono::Utc>>>;
}

impl SqlxRowExt for sqlx::postgres::PgRow {
    fn try_get_uuid(&self, column: &str) -> WorkflowResult<Uuid> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_i32(&self, column: &str) -> WorkflowResult<i32> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_i64(&self, column: &str) -> WorkflowResult<i64> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_string(&self, column: &str) -> WorkflowResult<String> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_optional_string(&self, column: &str) -> WorkflowResult<Option<String>> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_json(&self, column: &str) -> WorkflowResult<Option<serde_json::Value>> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_datetime(&self, column: &str) -> WorkflowResult<chrono::DateTime<chrono::Utc>> {
        self.try_get(column).map_err(WorkflowError::from)
    }
    
    fn try_get_optional_datetime(&self, column: &str) -> WorkflowResult<Option<chrono::DateTime<chrono::Utc>>> {
        self.try_get(column).map_err(WorkflowError::from)
    }
}
