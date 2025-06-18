use crate::traits::StepExecutionContext;
use crate::models::error::WorkflowResult;

/// Context builder for creating step execution contexts
#[derive(Debug, Default)]
pub struct ExecutionContextBuilder {
    workflow_data: Option<serde_json::Value>,
    step_data: Option<serde_json::Value>,
    persistence_data: Option<serde_json::Value>,
    correlation_id: Option<String>,
    workflow_instance_id: Option<uuid::Uuid>,
    step_id: Option<i32>,
    step_name: Option<String>,
    attempt: Option<i32>,
}

impl ExecutionContextBuilder {
    /// Create a new context builder
    pub fn new() -> Self {
        Self::default()
    }

    /// Set workflow data
    pub fn workflow_data(mut self, data: serde_json::Value) -> Self {
        self.workflow_data = Some(data);
        self
    }

    /// Set step data
    pub fn step_data(mut self, data: serde_json::Value) -> Self {
        self.step_data = Some(data);
        self
    }

    /// Set persistence data
    pub fn persistence_data(mut self, data: serde_json::Value) -> Self {
        self.persistence_data = Some(data);
        self
    }

    /// Set correlation ID
    pub fn correlation_id(mut self, id: String) -> Self {
        self.correlation_id = Some(id);
        self
    }

    /// Set workflow instance ID
    pub fn workflow_instance_id(mut self, id: uuid::Uuid) -> Self {
        self.workflow_instance_id = Some(id);
        self
    }

    /// Set step ID
    pub fn step_id(mut self, id: i32) -> Self {
        self.step_id = Some(id);
        self
    }

    /// Set step name
    pub fn step_name(mut self, name: String) -> Self {
        self.step_name = Some(name);
        self
    }

    /// Set attempt number
    pub fn attempt(mut self, attempt: i32) -> Self {
        self.attempt = Some(attempt);
        self
    }

    /// Build the execution context
    pub fn build(self) -> WorkflowResult<StepExecutionContext> {
        Ok(StepExecutionContext {
            workflow_data: self.workflow_data.unwrap_or_default(),
            step_data: self.step_data,
            persistence_data: self.persistence_data,
            correlation_id: self.correlation_id.unwrap_or_else(|| uuid::Uuid::new_v4().to_string()),
            workflow_instance_id: self.workflow_instance_id.unwrap_or_else(uuid::Uuid::new_v4),
            step_id: self.step_id.unwrap_or(0),
            step_name: self.step_name.unwrap_or_else(|| "unnamed_step".to_string()),
            attempt: self.attempt.unwrap_or(1),
            cancellation_token: tokio_util::sync::CancellationToken::new(),
        })
    }
}

/// Utility functions for execution context management
pub struct ExecutionContextUtils;

impl ExecutionContextUtils {
    /// Create a context for testing
    pub fn create_test_context() -> StepExecutionContext {
        ExecutionContextBuilder::new()
            .workflow_data(serde_json::json!({"test": "data"}))
            .correlation_id("test-correlation".to_string())
            .step_name("test_step".to_string())
            .build()
            .expect("Failed to create test context")
    }

    /// Create a context from workflow and execution pointer data
    pub fn from_workflow_data(
        workflow_data: Option<serde_json::Value>,
        step_id: i32,
        step_name: String,
        persistence_data: Option<serde_json::Value>,
        correlation_id: Option<String>,
        workflow_instance_id: uuid::Uuid,
        attempt: i32,
    ) -> WorkflowResult<StepExecutionContext> {
        ExecutionContextBuilder::new()
            .workflow_data(workflow_data.unwrap_or_default())
            .step_id(step_id)
            .step_name(step_name)
            .persistence_data(persistence_data.unwrap_or_default())
            .correlation_id(correlation_id.unwrap_or_else(|| uuid::Uuid::new_v4().to_string()))
            .workflow_instance_id(workflow_instance_id)
            .attempt(attempt)
            .build()
    }

    /// Clone a context with updated data
    pub fn clone_with_data(
        original: &StepExecutionContext,
        new_data: serde_json::Value,
    ) -> StepExecutionContext {
        StepExecutionContext {
            workflow_data: new_data,
            step_data: original.step_data.clone(),
            persistence_data: original.persistence_data.clone(),
            correlation_id: original.correlation_id.clone(),
            workflow_instance_id: original.workflow_instance_id,
            step_id: original.step_id,
            step_name: original.step_name.clone(),
            attempt: original.attempt,
            cancellation_token: tokio_util::sync::CancellationToken::new(),
        }
    }

    /// Update context for retry
    pub fn for_retry(original: &StepExecutionContext, attempt: i32) -> StepExecutionContext {
        StepExecutionContext {
            workflow_data: original.workflow_data.clone(),
            step_data: original.step_data.clone(),
            persistence_data: original.persistence_data.clone(),
            correlation_id: original.correlation_id.clone(),
            workflow_instance_id: original.workflow_instance_id,
            step_id: original.step_id,
            step_name: original.step_name.clone(),
            attempt,
            cancellation_token: tokio_util::sync::CancellationToken::new(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_context_builder() {
        let context = ExecutionContextBuilder::new()
            .workflow_data(serde_json::json!({"key": "value"}))
            .step_name("test_step".to_string())
            .correlation_id("test-123".to_string())
            .build()
            .unwrap();

        assert_eq!(context.step_name, "test_step");
        assert_eq!(context.correlation_id, "test-123");
        assert_eq!(context.workflow_data["key"], "value");
    }

    #[test]
    fn test_context_utils() {
        let test_context = ExecutionContextUtils::create_test_context();
        assert_eq!(test_context.step_name, "test_step");
        assert_eq!(test_context.correlation_id, "test-correlation");

        let cloned_context = ExecutionContextUtils::clone_with_data(
            &test_context,
            serde_json::json!({"updated": "data"}),
        );
        assert_eq!(cloned_context.workflow_data["updated"], "data");
        assert_eq!(cloned_context.step_name, test_context.step_name);

        let retry_context = ExecutionContextUtils::for_retry(&test_context, 2);
        assert_eq!(retry_context.attempt, 2);
        assert_eq!(retry_context.step_name, test_context.step_name);
    }

    #[test]
    fn test_context_from_workflow_data() {
        let context = ExecutionContextUtils::from_workflow_data(
            Some(serde_json::json!({"workflow": "data"})),
            1,
            "step_1".to_string(),
            Some(serde_json::json!({"persist": "data"})),
            Some("correlation-123".to_string()),
            uuid::Uuid::new_v4(),
            1,
        ).unwrap();

        assert_eq!(context.step_id, 1);
        assert_eq!(context.step_name, "step_1");
        assert_eq!(context.correlation_id, "correlation-123");
        assert_eq!(context.attempt, 1);
    }
}
