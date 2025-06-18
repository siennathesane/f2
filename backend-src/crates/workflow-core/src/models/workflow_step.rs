use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Arc;
use crate::traits::{StepBody, ErrorBehavior, RetryPolicy};

/// Workflow definition containing all steps and their relationships
#[derive(Debug, Clone)]
pub struct WorkflowDefinition {
    /// Unique identifier for this workflow
    pub id: String,
    
    /// Version number for this workflow
    pub version: i32,
    
    /// Optional human-readable description
    pub description: Option<String>,
    
    /// All steps in this workflow
    pub steps: Vec<WorkflowStep>,
    
    /// Default error behavior for steps
    pub default_error_behavior: Option<ErrorBehavior>,
    
    /// Default retry policy for steps
    pub default_retry_policy: Option<RetryPolicy>,
    
    /// Global workflow timeout
    pub timeout: Option<std::time::Duration>,
    
    /// Tags for categorizing workflows
    pub tags: Vec<String>,
    
    /// Metadata for workflow
    pub metadata: HashMap<String, String>,
}

impl WorkflowDefinition {
    /// Create a new workflow definition
    pub fn new(id: String, version: i32) -> Self {
        Self {
            id,
            version,
            description: None,
            steps: Vec::new(),
            default_error_behavior: None,
            default_retry_policy: None,
            timeout: None,
            tags: Vec::new(),
            metadata: HashMap::new(),
        }
    }

    /// Set description for this workflow
    pub fn with_description(mut self, description: String) -> Self {
        self.description = Some(description);
        self
    }

    /// Add tags to this workflow
    pub fn with_tags(mut self, tags: Vec<String>) -> Self {
        self.tags = tags;
        self
    }

    /// Set global timeout
    pub fn with_timeout(mut self, timeout: std::time::Duration) -> Self {
        self.timeout = Some(timeout);
        self
    }

    /// Set default error behavior
    pub fn with_default_error_behavior(mut self, behavior: ErrorBehavior) -> Self {
        self.default_error_behavior = Some(behavior);
        self
    }

    /// Set default retry policy
    pub fn with_default_retry_policy(mut self, policy: RetryPolicy) -> Self {
        self.default_retry_policy = Some(policy);
        self
    }

    /// Add a step to this workflow
    pub fn add_step(&mut self, step: WorkflowStep) {
        self.steps.push(step);
    }

    /// Get a step by ID
    pub fn get_step(&self, step_id: i32) -> Option<&WorkflowStep> {
        self.steps.iter().find(|s| s.id == step_id)
    }

    /// Get a step by name
    pub fn get_step_by_name(&self, name: &str) -> Option<&WorkflowStep> {
        self.steps.iter().find(|s| s.name == name)
    }

    /// Get the initial step (step with no predecessors)
    pub fn get_initial_step(&self) -> Option<&WorkflowStep> {
        self.steps.iter().find(|s| s.is_initial())
    }

    /// Get steps that have the given step as a predecessor
    pub fn get_next_steps(&self, step_id: i32) -> Vec<&WorkflowStep> {
        self.steps
            .iter()
            .filter(|s| s.children.contains(&step_id))
            .collect()
    }

    /// Validate the workflow definition
    pub fn validate(&self) -> Result<(), String> {
        // Check for duplicate step IDs
        let mut seen_ids = std::collections::HashSet::new();
        for step in &self.steps {
            if seen_ids.contains(&step.id) {
                return Err(format!("Duplicate step ID: {}", step.id));
            }
            seen_ids.insert(step.id);
        }

        // Check for duplicate step names
        let mut seen_names = std::collections::HashSet::new();
        for step in &self.steps {
            if seen_names.contains(&step.name) {
                return Err(format!("Duplicate step name: {}", step.name));
            }
            seen_names.insert(&step.name);
        }

        // Check that all child references are valid
        for step in &self.steps {
            for child_id in &step.children {
                if !seen_ids.contains(child_id) {
                    return Err(format!(
                        "Step {} references non-existent child step {}",
                        step.id, child_id
                    ));
                }
            }
        }

        // Check that there's exactly one initial step
        let initial_steps: Vec<_> = self.steps.iter().filter(|s| s.is_initial()).collect();
        if initial_steps.is_empty() {
            return Err("No initial step found (step with no predecessors)".to_string());
        }
        if initial_steps.len() > 1 {
            return Err("Multiple initial steps found".to_string());
        }

        Ok(())
    }

    /// Check if this workflow definition is empty
    pub fn is_empty(&self) -> bool {
        self.steps.is_empty()
    }

    /// Get the total number of steps
    pub fn step_count(&self) -> usize {
        self.steps.len()
    }

    /// Get all tags as a string for filtering
    pub fn tags_string(&self) -> String {
        self.tags.join(",")
    }
}

/// Individual step within a workflow
#[derive(Debug, Clone)]
pub struct WorkflowStep {
    /// Unique ID within the workflow
    pub id: i32,
    
    /// Human-readable name for this step
    pub name: String,
    
    /// Optional external identifier
    pub external_id: Option<String>,
    
    /// Child step IDs (steps that should execute after this one)
    pub children: Vec<i32>,
    
    /// Outcomes that determine which child steps to execute
    pub outcomes: Vec<StepOutcome>,
    
    /// Input mappings for this step
    pub inputs: Vec<StepParameter>,
    
    /// Output mappings for this step
    pub outputs: Vec<StepParameter>,
    
    /// Error behavior specific to this step
    pub error_behavior: Option<ErrorBehavior>,
    
    /// Retry policy specific to this step
    pub retry_policy: Option<RetryPolicy>,
    
    /// Timeout specific to this step
    pub timeout: Option<std::time::Duration>,
    
    /// Compensation step ID for saga patterns
    pub compensation_step_id: Option<i32>,
    
    /// Whether child steps should resume after compensation
    pub resume_children_after_compensation: bool,
    
    /// Whether child steps should be reverted after compensation
    pub revert_children_after_compensation: bool,
    
    /// Step body implementation
    pub step_body: Arc<dyn StepBody>,
    
    /// Whether this step should proceed on cancellation
    pub proceed_on_cancel: bool,
    
    /// Metadata for this step
    pub metadata: HashMap<String, String>,
}

impl WorkflowStep {
    /// Create a new workflow step
    pub fn new<T: StepBody + 'static>(
        id: i32,
        name: String,
        step_body: T,
    ) -> Self {
        Self {
            id,
            name,
            external_id: None,
            children: Vec::new(),
            outcomes: Vec::new(),
            inputs: Vec::new(),
            outputs: Vec::new(),
            error_behavior: None,
            retry_policy: None,
            timeout: None,
            compensation_step_id: None,
            resume_children_after_compensation: true,
            revert_children_after_compensation: false,
            step_body: Arc::new(step_body),
            proceed_on_cancel: false,
            metadata: HashMap::new(),
        }
    }

    /// Set external ID
    pub fn with_external_id(mut self, external_id: String) -> Self {
        self.external_id = Some(external_id);
        self
    }

    /// Add a child step
    pub fn with_child(mut self, child_id: i32) -> Self {
        if !self.children.contains(&child_id) {
            self.children.push(child_id);
        }
        self
    }

    /// Add multiple child steps
    pub fn with_children(mut self, child_ids: Vec<i32>) -> Self {
        for child_id in child_ids {
            if !self.children.contains(&child_id) {
                self.children.push(child_id);
            }
        }
        self
    }

    /// Set error behavior
    pub fn with_error_behavior(mut self, behavior: ErrorBehavior) -> Self {
        self.error_behavior = Some(behavior);
        self
    }

    /// Set retry policy
    pub fn with_retry_policy(mut self, policy: RetryPolicy) -> Self {
        self.retry_policy = Some(policy);
        self
    }

    /// Set timeout
    pub fn with_timeout(mut self, timeout: std::time::Duration) -> Self {
        self.timeout = Some(timeout);
        self
    }

    /// Set compensation step
    pub fn with_compensation(mut self, compensation_step_id: i32) -> Self {
        self.compensation_step_id = Some(compensation_step_id);
        self
    }

    /// Add an outcome
    pub fn with_outcome(mut self, outcome: StepOutcome) -> Self {
        self.outcomes.push(outcome);
        self
    }

    /// Add an input parameter
    pub fn with_input(mut self, input: StepParameter) -> Self {
        self.inputs.push(input);
        self
    }

    /// Add an output parameter
    pub fn with_output(mut self, output: StepParameter) -> Self {
        self.outputs.push(output);
        self
    }

    /// Add metadata
    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }

    /// Check if this is an initial step (no predecessors)
    pub fn is_initial(&self) -> bool {
        // This will be determined by the workflow builder
        // For now, assume step ID 0 or 1 is initial
        self.id == 0 || self.id == 1
    }

    /// Check if this is a terminal step (no children)
    pub fn is_terminal(&self) -> bool {
        self.children.is_empty()
    }

    /// Get the step body type name for debugging
    pub fn body_type_name(&self) -> &'static str {
        std::any::type_name::<Self>()
    }

    /// Check if this step has compensation
    pub fn has_compensation(&self) -> bool {
        self.compensation_step_id.is_some()
    }

    /// Get metadata value
    pub fn get_metadata(&self, key: &str) -> Option<&String> {
        self.metadata.get(key)
    }
}

/// Step outcome that determines workflow branching
#[derive(Debug, Clone)]
pub struct StepOutcome {
    /// Expected outcome value (None means any outcome)
    pub value: Option<serde_json::Value>,
    
    /// Next step ID to execute
    pub next_step: i32,
    
    /// Optional condition for this outcome
    pub condition: Option<String>, // Could be expanded to a proper expression evaluator
    
    /// Name for this outcome (for debugging)
    pub name: Option<String>,
}

impl StepOutcome {
    /// Create a new step outcome
    pub fn new(next_step: i32) -> Self {
        Self {
            value: None,
            next_step,
            condition: None,
            name: None,
        }
    }

    /// Create outcome with specific value
    pub fn with_value(next_step: i32, value: serde_json::Value) -> Self {
        Self {
            value: Some(value),
            next_step,
            condition: None,
            name: None,
        }
    }

    /// Create outcome with condition
    pub fn with_condition(next_step: i32, condition: String) -> Self {
        Self {
            value: None,
            next_step,
            condition: Some(condition),
            name: None,
        }
    }

    /// Set name for this outcome
    pub fn with_name(mut self, name: String) -> Self {
        self.name = Some(name);
        self
    }

    /// Check if this outcome matches the given value
    pub fn matches(&self, outcome_value: &Option<serde_json::Value>) -> bool {
        match (&self.value, outcome_value) {
            (None, _) => true, // Any outcome matches
            (Some(expected), Some(actual)) => expected == actual,
            (Some(_), None) => false,
        }
    }
}

/// Step parameter for input/output mapping
#[derive(Debug, Clone)]
pub struct StepParameter {
    /// Parameter name
    pub name: String,
    
    /// Source path in the workflow data (dot-notation)
    pub source_path: Option<String>,
    
    /// Target path in the step data (dot-notation)
    pub target_path: Option<String>,
    
    /// Default value if source is not available
    pub default_value: Option<serde_json::Value>,
    
    /// Whether this parameter is required
    pub required: bool,
    
    /// Parameter description
    pub description: Option<String>,
}

impl StepParameter {
    /// Create a new step parameter
    pub fn new(name: String) -> Self {
        Self {
            name,
            source_path: None,
            target_path: None,
            default_value: None,
            required: false,
            description: None,
        }
    }

    /// Set source path
    pub fn with_source(mut self, source_path: String) -> Self {
        self.source_path = Some(source_path);
        self
    }

    /// Set target path
    pub fn with_target(mut self, target_path: String) -> Self {
        self.target_path = Some(target_path);
        self
    }

    /// Set default value
    pub fn with_default(mut self, default_value: serde_json::Value) -> Self {
        self.default_value = Some(default_value);
        self
    }

    /// Mark as required
    pub fn required(mut self) -> Self {
        self.required = true;
        self
    }

    /// Set description
    pub fn with_description(mut self, description: String) -> Self {
        self.description = Some(description);
        self
    }
}

/// Serializable workflow definition for persistence
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SerializableWorkflowDefinition {
    pub id: String,
    pub version: i32,
    pub description: Option<String>,
    pub steps: Vec<SerializableWorkflowStep>,
    pub default_error_behavior: Option<String>,
    pub default_retry_policy: Option<SerializableRetryPolicy>,
    pub timeout_seconds: Option<u64>,
    pub tags: Vec<String>,
    pub metadata: HashMap<String, String>,
}

/// Serializable workflow step for persistence
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SerializableWorkflowStep {
    pub id: i32,
    pub name: String,
    pub external_id: Option<String>,
    pub children: Vec<i32>,
    pub outcomes: Vec<SerializableStepOutcome>,
    pub inputs: Vec<SerializableStepParameter>,
    pub outputs: Vec<SerializableStepParameter>,
    pub error_behavior: Option<String>,
    pub retry_policy: Option<SerializableRetryPolicy>,
    pub timeout_seconds: Option<u64>,
    pub compensation_step_id: Option<i32>,
    pub step_type: String, // For reconstructing the step body
    pub step_config: Option<serde_json::Value>, // Configuration for the step body
    pub metadata: HashMap<String, String>,
}

/// Serializable step outcome
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SerializableStepOutcome {
    pub value: Option<serde_json::Value>,
    pub next_step: i32,
    pub condition: Option<String>,
    pub name: Option<String>,
}

/// Serializable step parameter
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SerializableStepParameter {
    pub name: String,
    pub source_path: Option<String>,
    pub target_path: Option<String>,
    pub default_value: Option<serde_json::Value>,
    pub required: bool,
    pub description: Option<String>,
}

/// Serializable retry policy
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SerializableRetryPolicy {
    pub max_attempts: u32,
    pub delay_seconds: f64,
    pub backoff_multiplier: f64,
    pub max_delay_seconds: f64,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_workflow_definition_creation() {
        let definition = WorkflowDefinition::new("test_workflow".to_string(), 1)
            .with_description("Test workflow".to_string())
            .with_tags(vec!["test".to_string(), "example".to_string()]);

        assert_eq!(definition.id, "test_workflow");
        assert_eq!(definition.version, 1);
        assert_eq!(definition.description, Some("Test workflow".to_string()));
        assert_eq!(definition.tags.len(), 2);
        assert!(definition.is_empty());
    }

    #[test]
    fn test_step_outcome() {
        let outcome = StepOutcome::with_value(2, serde_json::json!("success"))
            .with_name("Success Path".to_string());

        assert_eq!(outcome.next_step, 2);
        assert!(outcome.matches(&Some(serde_json::json!("success"))));
        assert!(!outcome.matches(&Some(serde_json::json!("failure"))));

        let any_outcome = StepOutcome::new(3);
        assert!(any_outcome.matches(&Some(serde_json::json!("anything"))));
        assert!(any_outcome.matches(&None));
    }

    #[test]
    fn test_step_parameter() {
        let param = StepParameter::new("user_id".to_string())
            .with_source("workflow_data.user.id".to_string())
            .with_target("request.user_id".to_string())
            .with_default(serde_json::json!(null))
            .required()
            .with_description("ID of the user".to_string());

        assert_eq!(param.name, "user_id");
        assert_eq!(param.source_path, Some("workflow_data.user.id".to_string()));
        assert_eq!(param.target_path, Some("request.user_id".to_string()));
        assert!(param.required);
        assert_eq!(param.description, Some("ID of the user".to_string()));
    }
}
