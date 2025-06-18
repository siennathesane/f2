use async_trait::async_trait;
use crate::models::error::WorkflowResult;
use crate::execution_result::ExecutionResult;
use std::fmt::Debug;

/// Context provided to step execution
#[derive(Debug)]
pub struct StepExecutionContext {
    /// Current workflow instance data
    pub workflow_data: serde_json::Value,
    
    /// Step-specific input data
    pub step_data: Option<serde_json::Value>,
    
    /// Persistence data from previous execution (for resuming)
    pub persistence_data: Option<serde_json::Value>,
    
    /// Correlation ID for tracing
    pub correlation_id: String,
    
    /// Workflow instance ID
    pub workflow_instance_id: uuid::Uuid,
    
    /// Step ID within the workflow
    pub step_id: i32,
    
    /// Step name for logging/debugging
    pub step_name: String,
    
    /// Current attempt number (for retries)
    pub attempt: i32,
    
    /// Cancellation token for graceful shutdown
    pub cancellation_token: tokio_util::sync::CancellationToken,
}

impl StepExecutionContext {
    /// Get workflow data as a specific type
    pub fn get_workflow_data<T: for<'de> serde::Deserialize<'de>>(&self) -> Option<T> {
        serde_json::from_value(self.workflow_data.clone()).ok()
    }

    /// Get step data as a specific type
    pub fn get_step_data<T: for<'de> serde::Deserialize<'de>>(&self) -> Option<T> {
        self.step_data
            .as_ref()
            .and_then(|d| serde_json::from_value(d.clone()).ok())
    }

    /// Get persistence data as a specific type
    pub fn get_persistence_data<T: for<'de> serde::Deserialize<'de>>(&self) -> Option<T> {
        self.persistence_data
            .as_ref()
            .and_then(|d| serde_json::from_value(d.clone()).ok())
    }

    /// Update workflow data
    pub fn set_workflow_data<T: serde::Serialize>(&mut self, data: T) -> WorkflowResult<()> {
        self.workflow_data = serde_json::to_value(data)?;
        Ok(())
    }

    /// Check if cancellation was requested
    pub fn is_cancelled(&self) -> bool {
        self.cancellation_token.is_cancelled()
    }
}

/// Core trait for implementing workflow steps
/// 
/// This is the main interface for implementing custom workflow logic.
/// Steps can be stateless (pure functions) or stateful (maintaining internal state).
#[async_trait]
pub trait StepBody: Send + Sync + Debug {
    /// Execute the step with the given context
    /// 
    /// Returns an ExecutionResult that controls workflow progression:
    /// - ExecutionResult::next() - Proceed to next step
    /// - ExecutionResult::outcome(value) - Proceed with outcome value
    /// - ExecutionResult::persist(data) - Pause and resume later with data
    /// - ExecutionResult::sleep(duration, data) - Sleep then resume
    /// - ExecutionResult::wait_for_event(name, key, date) - Wait for external event
    /// - ExecutionResult::branch(values, data) - Create parallel branches
    async fn run(&self, context: &StepExecutionContext) -> WorkflowResult<ExecutionResult>;

    /// Optional step name for debugging/logging
    fn name(&self) -> &str {
        std::any::type_name::<Self>()
    }

    /// Optional setup called before first execution
    async fn setup(&self, _context: &StepExecutionContext) -> WorkflowResult<()> {
        Ok(())
    }

    /// Optional cleanup called after successful completion
    async fn cleanup(&self, _context: &StepExecutionContext) -> WorkflowResult<()> {
        Ok(())
    }

    /// Optional compensation logic for saga patterns
    async fn compensate(&self, _context: &StepExecutionContext) -> WorkflowResult<()> {
        Ok(())
    }

    /// Check if this step can be retried on failure
    fn can_retry(&self) -> bool {
        true
    }

    /// Maximum retry attempts (0 = no retries, None = unlimited)
    fn max_retries(&self) -> Option<u32> {
        Some(3)
    }

    /// Delay between retry attempts
    fn retry_delay(&self) -> std::time::Duration {
        std::time::Duration::from_secs(1)
    }
}

/// Helper macro for implementing simple inline steps
/// 
/// Usage:
/// ```rust
/// use workflow_core::impl_step;
///
/// impl_step!(MyStep, |context| async {
///     // Step logic here
///     Ok(ExecutionResult::next())
/// });
/// ```
#[macro_export]
macro_rules! impl_step {
    ($name:ident, $body:expr) => {
        #[derive(Debug)]
        pub struct $name;

        #[async_trait::async_trait]
        impl $crate::traits::step_body::StepBody for $name {
            async fn run(
                &self,
                context: &$crate::traits::step_body::StepExecutionContext,
            ) -> $crate::models::error::WorkflowResult<$crate::execution_result::ExecutionResult> {
                let closure: fn(&$crate::traits::step_body::StepExecutionContext) 
                    -> std::pin::Pin<Box<dyn std::future::Future<Output = $crate::models::error::WorkflowResult<$crate::execution_result::ExecutionResult>> + Send + '_>> = $body;
                closure(context).await
            }
        }
    };
}

#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;

    #[tokio::test]
    async fn test_step_execution_context() {
        let context = StepExecutionContext {
            workflow_data: serde_json::json!({"test": "data"}),
            step_data: Some(serde_json::json!({"step": "input"})),
            persistence_data: None,
            correlation_id: "test-correlation".to_string(),
            workflow_instance_id: Uuid::new_v4(),
            step_id: 1,
            step_name: "TestStep".to_string(),
            attempt: 1,
            cancellation_token: tokio_util::sync::CancellationToken::new(),
        };

        #[derive(serde::Deserialize)]
        struct TestData {
            test: String,
        }

        let data = context.get_workflow_data::<TestData>().unwrap();
        assert_eq!(data.test, "data");
    }
}
