use async_trait::async_trait;
use std::sync::Arc;
use crate::traits::{StepBody, StepExecutionContext};
use crate::execution_result::ExecutionResult;
use crate::models::error::{WorkflowResult, WorkflowError};

/// Individual step executor responsible for running a single step
#[derive(Debug)]
pub struct StepExecutor {
    /// Maximum time to wait for step completion
    pub timeout: std::time::Duration,
    
    /// Whether to enable detailed logging
    pub enable_logging: bool,
}

impl StepExecutor {
    /// Create a new step executor with default configuration
    pub fn new() -> Self {
        Self {
            timeout: std::time::Duration::from_secs(300), // 5 minutes
            enable_logging: true,
        }
    }

    /// Create a step executor with custom timeout
    pub fn with_timeout(timeout: std::time::Duration) -> Self {
        Self {
            timeout,
            enable_logging: true,
        }
    }

    /// Execute a step with error handling and logging
    pub async fn execute(
        &self,
        step_body: Arc<dyn StepBody>,
        context: &StepExecutionContext,
    ) -> WorkflowResult<ExecutionResult> {
        if self.enable_logging {
            tracing::info!(
                step_name = %context.step_name,
                step_id = %context.step_id,
                workflow_instance_id = %context.workflow_instance_id,
                correlation_id = %context.correlation_id,
                attempt = %context.attempt,
                "Starting step execution"
            );
        }

        let start_time = std::time::Instant::now();

        // Check for cancellation before starting
        if context.cancellation_token.is_cancelled() {
            return Err(WorkflowError::StepExecutionFailed {
                step_name: context.step_name.clone(),
                reason: "Step execution was cancelled".to_string(),
            });
        }

        // Execute step with timeout
        let result = tokio::time::timeout(
            self.timeout,
            self.execute_with_cancellation(step_body, context)
        ).await;

        let execution_duration = start_time.elapsed();

        match result {
            Ok(step_result) => {
                match &step_result {
                    Ok(exec_result) => {
                        if self.enable_logging {
                            tracing::info!(
                                step_name = %context.step_name,
                                duration_ms = execution_duration.as_millis(),
                                proceed = exec_result.proceed,
                                "Step execution completed successfully"
                            );
                        }
                    }
                    Err(error) => {
                        if self.enable_logging {
                            tracing::error!(
                                step_name = %context.step_name,
                                duration_ms = execution_duration.as_millis(),
                                error = %error,
                                "Step execution failed"
                            );
                        }
                    }
                }
                step_result
            }
            Err(_) => {
                let error = WorkflowError::StepExecutionFailed {
                    step_name: context.step_name.clone(),
                    reason: format!("Step execution timeout after {:?}", self.timeout),
                };
                
                if self.enable_logging {
                    tracing::error!(
                        step_name = %context.step_name,
                        timeout_ms = self.timeout.as_millis(),
                        "Step execution timed out"
                    );
                }
                
                Err(error)
            }
        }
    }

    /// Execute step with cancellation support
    async fn execute_with_cancellation(
        &self,
        step_body: Arc<dyn StepBody>,
        context: &StepExecutionContext,
    ) -> WorkflowResult<ExecutionResult> {
        // Create a cancellation-aware future
        tokio::select! {
            result = step_body.run(context) => result,
            _ = context.cancellation_token.cancelled() => {
                Err(WorkflowError::StepExecutionFailed {
                    step_name: context.step_name.clone(),
                    reason: "Step execution was cancelled".to_string(),
                })
            }
        }
    }

    /// Execute step setup if available
    pub async fn execute_setup(
        &self,
        step_body: Arc<dyn StepBody>,
        context: &StepExecutionContext,
    ) -> WorkflowResult<()> {
        if self.enable_logging {
            tracing::debug!(
                step_name = %context.step_name,
                "Executing step setup"
            );
        }

        step_body.setup(context).await
    }

    /// Execute step cleanup if available
    pub async fn execute_cleanup(
        &self,
        step_body: Arc<dyn StepBody>,
        context: &StepExecutionContext,
    ) -> WorkflowResult<()> {
        if self.enable_logging {
            tracing::debug!(
                step_name = %context.step_name,
                "Executing step cleanup"
            );
        }

        step_body.cleanup(context).await
    }

    /// Execute step compensation if available
    pub async fn execute_compensation(
        &self,
        step_body: Arc<dyn StepBody>,
        context: &StepExecutionContext,
    ) -> WorkflowResult<()> {
        if self.enable_logging {
            tracing::info!(
                step_name = %context.step_name,
                "Executing step compensation"
            );
        }

        step_body.compensate(context).await
    }

    /// Check if a step can be retried
    pub fn can_retry(
        &self,
        step_body: &Arc<dyn StepBody>,
        current_attempt: i32,
        error: &WorkflowError,
    ) -> bool {
        // Check if step allows retries
        if !step_body.can_retry() {
            return false;
        }

        // Check if error is retryable
        if !error.should_retry() {
            return false;
        }

        // Check max retry limit
        if let Some(max_retries) = step_body.max_retries() {
            return current_attempt <= max_retries as i32;
        }

        // Default: allow retry
        true
    }

    /// Calculate delay before retry
    pub fn calculate_retry_delay(
        &self,
        step_body: &Arc<dyn StepBody>,
        attempt: i32,
    ) -> std::time::Duration {
        let base_delay = step_body.retry_delay();
        
        // Simple exponential backoff: delay * 2^(attempt-1)
        let multiplier = if attempt > 1 { 2_u32.pow((attempt - 1) as u32) } else { 1 };
        let calculated_delay = base_delay * multiplier;
        
        // Cap at 5 minutes
        std::cmp::min(calculated_delay, std::time::Duration::from_secs(300))
    }
}

impl Default for StepExecutor {
    fn default() -> Self {
        Self::new()
    }
}

/// Statistics for step execution
#[derive(Debug, Clone, Default)]
pub struct StepExecutionStats {
    pub total_executions: u64,
    pub successful_executions: u64,
    pub failed_executions: u64,
    pub retried_executions: u64,
    pub total_duration: std::time::Duration,
    pub average_duration: std::time::Duration,
}

impl StepExecutionStats {
    /// Record a successful execution
    pub fn record_success(&mut self, duration: std::time::Duration) {
        self.total_executions += 1;
        self.successful_executions += 1;
        self.total_duration += duration;
        self.update_average();
    }

    /// Record a failed execution
    pub fn record_failure(&mut self, duration: std::time::Duration) {
        self.total_executions += 1;
        self.failed_executions += 1;
        self.total_duration += duration;
        self.update_average();
    }

    /// Record a retry
    pub fn record_retry(&mut self) {
        self.retried_executions += 1;
    }

    /// Calculate success rate as percentage
    pub fn success_rate(&self) -> f64 {
        if self.total_executions == 0 {
            0.0
        } else {
            (self.successful_executions as f64 / self.total_executions as f64) * 100.0
        }
    }

    /// Calculate retry rate as percentage
    pub fn retry_rate(&self) -> f64 {
        if self.total_executions == 0 {
            0.0
        } else {
            (self.retried_executions as f64 / self.total_executions as f64) * 100.0
        }
    }

    fn update_average(&mut self) {
        if self.total_executions > 0 {
            self.average_duration = self.total_duration / self.total_executions as u32;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::execution::context::ExecutionContextUtils;
    use crate::traits::step_body::grpc_steps::ExampleGrpcStep;
    use crate::simple_step;

    #[tokio::test]
    async fn test_step_executor_success() {
        let executor = StepExecutor::new();
        let step_body = Arc::new(ExampleGrpcStep::new(
            "test_service".to_string(),
            "http://localhost:50051".to_string(),
        ));
        let context = ExecutionContextUtils::create_test_context();

        let result = executor.execute(step_body, &context).await;
        assert!(result.is_ok());
        
        let exec_result = result.unwrap();
        assert!(exec_result.proceed);
    }

    #[tokio::test]
    async fn test_step_executor_timeout() {
        let executor = StepExecutor::with_timeout(std::time::Duration::from_millis(1));
        
        // Create a step that will timeout
        simple_step!(SlowStep, |_context| async move {
            tokio::time::sleep(std::time::Duration::from_millis(100)).await;
            Ok(ExecutionResult::next())
        });
        
        let step_body = Arc::new(SlowStep);
        let context = ExecutionContextUtils::create_test_context();

        let result = executor.execute(step_body, &context).await;
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn test_step_executor_cancellation() {
        let executor = StepExecutor::new();
        let mut context = ExecutionContextUtils::create_test_context();
        
        // Cancel the context
        context.cancellation_token.cancel();
        
        simple_step!(TestStep, |_context| async move {
            Ok(ExecutionResult::next())
        });
        
        let step_body = Arc::new(TestStep);
        let result = executor.execute(step_body, &context).await;
        assert!(result.is_err());
    }

    #[test]
    fn test_step_execution_stats() {
        let mut stats = StepExecutionStats::default();
        
        stats.record_success(std::time::Duration::from_millis(100));
        stats.record_success(std::time::Duration::from_millis(200));
        stats.record_failure(std::time::Duration::from_millis(50));
        stats.record_retry();

        assert_eq!(stats.total_executions, 3);
        assert_eq!(stats.successful_executions, 2);
        assert_eq!(stats.failed_executions, 1);
        assert_eq!(stats.retried_executions, 1);
        assert!((stats.success_rate() - 66.66666666666666).abs() < 0.001);
        assert!((stats.retry_rate() - 33.333333333333336).abs() < 0.001);
    }

    #[test]
    fn test_retry_logic() {
        let executor = StepExecutor::new();
        let step_body = Arc::new(ExampleGrpcStep::new(
            "test".to_string(),
            "http://test".to_string(),
        ));
        
        let retryable_error = WorkflowError::GrpcServiceError {
            service: "test".to_string(),
            message: "timeout".to_string(),
        };
        
        assert!(executor.can_retry(&step_body, 1, &retryable_error));
        assert!(executor.can_retry(&step_body, 3, &retryable_error));
        assert!(!executor.can_retry(&step_body, 5, &retryable_error)); // Exceeds max retries

        let non_retryable_error = WorkflowError::AuthenticationError("invalid token".to_string());
        assert!(!executor.can_retry(&step_body, 1, &non_retryable_error));
    }

    #[test]
    fn test_retry_delay_calculation() {
        let executor = StepExecutor::new();
        let step_body = Arc::new(ExampleGrpcStep::new(
            "test".to_string(),
            "http://test".to_string(),
        ));
        
        let delay1 = executor.calculate_retry_delay(&step_body, 1);
        let delay2 = executor.calculate_retry_delay(&step_body, 2);
        let delay3 = executor.calculate_retry_delay(&step_body, 3);
        
        // Should be exponential backoff
        assert!(delay2 >= delay1);
        assert!(delay3 >= delay2);
        
        // Should be capped at 5 minutes
        let delay_large = executor.calculate_retry_delay(&step_body, 20);
        assert_eq!(delay_large, std::time::Duration::from_secs(300));
    }
}
