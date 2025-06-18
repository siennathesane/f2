use crate::models::error::WorkflowResult;
use std::fmt::Debug;
use crate::traits::workflow_builder::WorkflowBuilder;

/// Core trait for defining workflows
/// 
/// Workflows define a series of steps that can be executed in sequence,
/// parallel, or with conditional branching. They can maintain state
/// between step executions and handle errors gracefully.
pub trait Workflow<T>: Send + Sync + Debug
where
    T: Send + Sync + Clone + 'static,
{
    /// Unique identifier for this workflow definition
    fn id(&self) -> &str;

    /// Version number for this workflow definition
    /// Used for backward compatibility and migrations
    fn version(&self) -> i32;

    /// Optional human-readable description
    fn description(&self) -> Option<&str> {
        None
    }

    /// Build the workflow definition using the fluent API
    /// 
    /// This is where you define the sequence of steps, branching logic,
    /// error handling, and compensation patterns.
    fn build(&self, builder: &mut dyn WorkflowBuilder<T>) -> WorkflowResult<()>;

    /// Optional default error behavior for all steps
    fn default_error_behavior(&self) -> Option<ErrorBehavior> {
        None
    }

    /// Optional default retry policy for all steps
    fn default_retry_policy(&self) -> Option<RetryPolicy> {
        Some(RetryPolicy {
            max_attempts: 3,
            delay: std::time::Duration::from_secs(1),
            backoff_multiplier: 2.0,
            max_delay: std::time::Duration::from_secs(60),
        })
    }

    /// Optional workflow timeout
    fn timeout(&self) -> Option<std::time::Duration> {
        None
    }

    /// Tags for categorizing workflows (useful for monitoring/filtering)
    fn tags(&self) -> Vec<String> {
        vec![]
    }
}

/// Untyped workflow trait for dynamic dispatch
pub trait UntypedWorkflow: Send + Sync + Debug {
    fn id(&self) -> &str;
    fn version(&self) -> i32;
    fn description(&self) -> Option<&str>;
    fn tags(&self) -> Vec<String>;
}

/// Implement UntypedWorkflow for any typed Workflow with serde_json::Value
impl<W> UntypedWorkflow for W
where
    W: Workflow<serde_json::Value>,
{
    fn id(&self) -> &str {
        Workflow::<serde_json::Value>::id(self)
    }

    fn version(&self) -> i32 {
        Workflow::<serde_json::Value>::version(self)
    }

    fn description(&self) -> Option<&str> {
        Workflow::<serde_json::Value>::description(self)
    }

    fn tags(&self) -> Vec<String> {
        Workflow::<serde_json::Value>::tags(self)
    }
}

/// Error handling behavior for workflow steps
#[derive(Debug, Clone, Copy)]
pub enum ErrorBehavior {
    /// Retry the step with the configured retry policy
    Retry,
    /// Suspend the workflow (manual intervention required)
    Suspend,
    /// Terminate the workflow immediately
    Terminate,
    /// Compensate (run compensation steps) then terminate
    Compensate,
    /// Continue to next step (ignore the error)
    Continue,
}

/// Retry policy configuration
#[derive(Debug, Clone)]
pub struct RetryPolicy {
    /// Maximum number of retry attempts
    pub max_attempts: u32,
    /// Initial delay between retries
    pub delay: std::time::Duration,
    /// Multiplier for exponential backoff
    pub backoff_multiplier: f64,
    /// Maximum delay between retries
    pub max_delay: std::time::Duration,
}

impl RetryPolicy {
    /// Create a simple retry policy with fixed delay
    pub fn fixed_delay(max_attempts: u32, delay: std::time::Duration) -> Self {
        Self {
            max_attempts,
            delay,
            backoff_multiplier: 1.0,
            max_delay: delay,
        }
    }

    /// Create an exponential backoff retry policy
    pub fn exponential_backoff(
        max_attempts: u32,
        initial_delay: std::time::Duration,
        multiplier: f64,
    ) -> Self {
        Self {
            max_attempts,
            delay: initial_delay,
            backoff_multiplier: multiplier,
            max_delay: std::time::Duration::from_secs(300), // 5 minutes max
        }
    }

    /// Calculate delay for a specific attempt
    pub fn delay_for_attempt(&self, attempt: u32) -> std::time::Duration {
        if attempt == 0 {
            return self.delay;
        }

        let delay_ms = self.delay.as_millis() as f64;
        let calculated_delay = delay_ms * self.backoff_multiplier.powi(attempt as i32);
        let delay = std::time::Duration::from_millis(calculated_delay as u64);
        
        std::cmp::min(delay, self.max_delay)
    }
}



#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_retry_policy() {
        let policy = RetryPolicy::exponential_backoff(
            3,
            std::time::Duration::from_millis(100),
            2.0,
        );

        assert_eq!(policy.delay_for_attempt(0), std::time::Duration::from_millis(100));
        assert_eq!(policy.delay_for_attempt(1), std::time::Duration::from_millis(200));
        assert_eq!(policy.delay_for_attempt(2), std::time::Duration::from_millis(400));
    }

    #[test]
    fn test_error_behavior() {
        let behavior = ErrorBehavior::Retry;
        // Just test that the enum variants exist
        match behavior {
            ErrorBehavior::Retry => assert!(true),
            ErrorBehavior::Suspend => assert!(false),
            ErrorBehavior::Terminate => assert!(false),
            ErrorBehavior::Compensate => assert!(false),
            ErrorBehavior::Continue => assert!(false),
        }
    }
}
