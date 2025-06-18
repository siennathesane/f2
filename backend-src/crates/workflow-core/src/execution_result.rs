use std::time::Duration;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Result of step execution, controlling workflow progression
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionResult {
    /// Whether the workflow should proceed to the next step
    pub proceed: bool,
    
    /// Outcome value that can be used for branching decisions
    pub outcome_value: Option<serde_json::Value>,
    
    /// Duration to sleep before continuing execution
    pub sleep_for: Option<Duration>,
    
    /// Data to persist between step executions
    pub persistence_data: Option<serde_json::Value>,
    
    /// Event name to wait for (for event-driven workflows)
    pub event_name: Option<String>,
    
    /// Event key for filtering specific events
    pub event_key: Option<String>,
    
    /// Effective date for event subscription
    pub event_as_of: Option<DateTime<Utc>>,
    
    /// Additional data for event subscriptions
    pub subscription_data: Option<serde_json::Value>,
    
    /// Values for parallel branch execution
    pub branch_values: Vec<serde_json::Value>,
}

impl Default for ExecutionResult {
    fn default() -> Self {
        Self::new()
    }
}

impl ExecutionResult {
    /// Create a new execution result with default values
    pub fn new() -> Self {
        ExecutionResult {
            proceed: false,
            outcome_value: None,
            sleep_for: None,
            persistence_data: None,
            event_name: None,
            event_key: None,
            event_as_of: None,
            subscription_data: None,
            branch_values: Vec::new(),
        }
    }

    /// Create result with an outcome value (proceeds to next step)
    pub fn with_outcome<T: Serialize>(outcome: T) -> Self {
        ExecutionResult {
            proceed: true,
            outcome_value: serde_json::to_value(outcome).ok(),
            ..Default::default()
        }
    }

    /// Create result with an outcome value (proceeds to next step)
    pub fn outcome<T: Serialize>(value: T) -> Self {
        Self::with_outcome(value)
    }

    /// Proceed to the next step without an outcome value
    pub fn next() -> Self {
        ExecutionResult {
            proceed: true,
            ..Default::default()
        }
    }

    /// Persist data and pause execution (will resume from this step)
    pub fn persist<T: Serialize>(persistence_data: T) -> Self {
        ExecutionResult {
            proceed: false,
            persistence_data: serde_json::to_value(persistence_data).ok(),
            ..Default::default()
        }
    }

    /// Create parallel branches with values
    pub fn branch<T: Serialize>(
        branches: Vec<T>, 
        persistence_data: Option<serde_json::Value>
    ) -> Self {
        let branch_values = branches
            .into_iter()
            .filter_map(|b| serde_json::to_value(b).ok())
            .collect();

        ExecutionResult {
            proceed: false,
            persistence_data,
            branch_values,
            ..Default::default()
        }
    }

    /// Sleep for a duration with optional persistence data
    pub fn sleep<T: Serialize>(
        duration: Duration, 
        persistence_data: Option<T>
    ) -> Self {
        ExecutionResult {
            proceed: false,
            sleep_for: Some(duration),
            persistence_data: persistence_data
                .and_then(|d| serde_json::to_value(d).ok()),
            ..Default::default()
        }
    }

    /// Wait for a specific event before continuing
    pub fn wait_for_event(
        event_name: String, 
        event_key: String, 
        effective_date: DateTime<Utc>
    ) -> Self {
        ExecutionResult {
            proceed: false,
            event_name: Some(event_name),
            event_key: Some(event_key),
            event_as_of: Some(effective_date),
            ..Default::default()
        }
    }

    /// Wait for an activity (external action) before continuing
    pub fn wait_for_activity<T: Serialize>(
        activity_name: String,
        subscription_data: T,
        effective_date: DateTime<Utc>
    ) -> Self {
        const EVENT_TYPE_ACTIVITY: &str = "workflow_core.activity";

        ExecutionResult {
            proceed: false,
            event_name: Some(EVENT_TYPE_ACTIVITY.to_string()),
            event_key: Some(activity_name),
            subscription_data: serde_json::to_value(subscription_data).ok(),
            event_as_of: Some(effective_date),
            ..Default::default()
        }
    }

    /// Check if this result represents a successful completion
    pub fn is_complete(&self) -> bool {
        self.proceed && self.event_name.is_none()
    }

    /// Check if this result is waiting for an event
    pub fn is_waiting_for_event(&self) -> bool {
        !self.proceed && self.event_name.is_some()
    }

    /// Check if this result is sleeping
    pub fn is_sleeping(&self) -> bool {
        !self.proceed && self.sleep_for.is_some()
    }

    /// Check if this result creates branches
    pub fn has_branches(&self) -> bool {
        !self.branch_values.is_empty()
    }

    /// Get the outcome value as a specific type
    pub fn get_outcome<T: for<'de> Deserialize<'de>>(&self) -> Option<T> {
        self.outcome_value
            .as_ref()
            .and_then(|v| serde_json::from_value(v.clone()).ok())
    }

    /// Get persistence data as a specific type
    pub fn get_persistence_data<T: for<'de> Deserialize<'de>>(&self) -> Option<T> {
        self.persistence_data
            .as_ref()
            .and_then(|v| serde_json::from_value(v.clone()).ok())
    }
}

/// Builder for creating complex execution results
#[derive(Debug, Default)]
pub struct ExecutionResultBuilder {
    result: ExecutionResult,
}

impl ExecutionResultBuilder {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn proceed(mut self, proceed: bool) -> Self {
        self.result.proceed = proceed;
        self
    }

    pub fn outcome<T: Serialize>(mut self, value: T) -> Self {
        self.result.outcome_value = serde_json::to_value(value).ok();
        self
    }

    pub fn sleep(mut self, duration: Duration) -> Self {
        self.result.sleep_for = Some(duration);
        self
    }

    pub fn persistence_data<T: Serialize>(mut self, data: T) -> Self {
        self.result.persistence_data = serde_json::to_value(data).ok();
        self
    }

    pub fn wait_for_event(mut self, event_name: String, event_key: String) -> Self {
        self.result.event_name = Some(event_name);
        self.result.event_key = Some(event_key);
        self.result.event_as_of = Some(Utc::now());
        self
    }

    pub fn build(self) -> ExecutionResult {
        self.result
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_execution_result_next() {
        let result = ExecutionResult::next();
        assert!(result.proceed);
        assert!(result.is_complete());
    }

    #[test]
    fn test_execution_result_with_outcome() {
        let result = ExecutionResult::outcome("success");
        assert!(result.proceed);
        assert_eq!(result.get_outcome::<String>(), Some("success".to_string()));
    }

    #[test]
    fn test_execution_result_persist() {
        let data = json!({"step": "processing", "progress": 50});
        let result = ExecutionResult::persist(data.clone());
        assert!(!result.proceed);
        assert_eq!(result.persistence_data, Some(data));
    }

    #[test]
    fn test_execution_result_sleep() {
        let duration = Duration::from_secs(60);
        let result = ExecutionResult::sleep(duration, Some("sleeping"));
        assert!(!result.proceed);
        assert!(result.is_sleeping());
        assert_eq!(result.sleep_for, Some(duration));
    }

    #[test]
    fn test_execution_result_wait_for_event() {
        let result = ExecutionResult::wait_for_event(
            "user_confirmation".to_string(),
            "user_123".to_string(),
            Utc::now()
        );
        assert!(!result.proceed);
        assert!(result.is_waiting_for_event());
    }

    #[test]
    fn test_builder_pattern() {
        let result = ExecutionResultBuilder::new()
            .proceed(true)
            .outcome("completed")
            .persistence_data(json!({"final": true}))
            .build();

        assert!(result.proceed);
        assert_eq!(result.get_outcome::<String>(), Some("completed".to_string()));
    }
}
