use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use crate::models::execution_pointer::ExecutionPointer;

/// Workflow instance represents a running workflow with its current state
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkflowInstance {
    /// Unique identifier for this workflow instance
    pub id: Uuid,
    
    /// ID of the workflow definition this instance is based on
    pub workflow_definition_id: String,
    
    /// Version of the workflow definition
    pub version: i32,
    
    /// Optional human-readable description
    pub description: Option<String>,
    
    /// Optional external reference for correlation
    pub reference: Option<String>,
    
    /// Current execution pointers (active steps)
    pub execution_pointers: Vec<ExecutionPointer>,
    
    /// Next scheduled execution time (None = runnable now)
    pub next_execution: Option<DateTime<Utc>>,
    
    /// Current workflow status
    pub status: WorkflowStatus,
    
    /// Workflow data (can be any JSON serializable data)
    pub data: Option<serde_json::Value>,
    
    /// When this workflow instance was created
    pub create_time: DateTime<Utc>,
    
    /// When this workflow completed (if applicable)
    pub complete_time: Option<DateTime<Utc>>,
    
    /// Correlation ID for distributed tracing
    pub correlation_id: Option<String>,
    
    /// Node ID for distributed execution
    pub node_id: Option<String>,
}

impl WorkflowInstance {
    /// Create a new workflow instance
    pub fn new(
        workflow_definition_id: String,
        version: i32,
        data: Option<serde_json::Value>,
    ) -> Self {
        Self {
            id: Uuid::new_v4(),
            workflow_definition_id,
            version,
            description: None,
            reference: None,
            execution_pointers: Vec::new(),
            next_execution: None,
            status: WorkflowStatus::Runnable,
            data,
            create_time: Utc::now(),
            complete_time: None,
            correlation_id: Some(Uuid::new_v4().to_string()),
            node_id: None,
        }
    }

    /// Create a workflow instance with a specific ID (for testing or resuming)
    pub fn with_id(
        id: Uuid,
        workflow_definition_id: String,
        version: i32,
        data: Option<serde_json::Value>,
    ) -> Self {
        Self {
            id,
            workflow_definition_id,
            version,
            description: None,
            reference: None,
            execution_pointers: Vec::new(),
            next_execution: None,
            status: WorkflowStatus::Runnable,
            data,
            create_time: Utc::now(),
            complete_time: None,
            correlation_id: Some(Uuid::new_v4().to_string()),
            node_id: None,
        }
    }

    /// Set description for this workflow instance
    pub fn with_description(mut self, description: String) -> Self {
        self.description = Some(description);
        self
    }

    /// Set external reference
    pub fn with_reference(mut self, reference: String) -> Self {
        self.reference = Some(reference);
        self
    }

    /// Set correlation ID
    pub fn with_correlation_id(mut self, correlation_id: String) -> Self {
        self.correlation_id = Some(correlation_id);
        self
    }

    /// Set node ID for distributed execution
    pub fn with_node_id(mut self, node_id: String) -> Self {
        self.node_id = Some(node_id);
        self
    }

    /// Check if all execution pointers in a branch are complete
    pub fn is_branch_complete(&self, scope: &[String]) -> bool {
        self.execution_pointers
            .iter()
            .filter(|p| p.scope == scope)
            .all(|p| p.end_time.is_some())
    }

    /// Get active execution pointers
    pub fn get_active_pointers(&self) -> Vec<&ExecutionPointer> {
        self.execution_pointers
            .iter()
            .filter(|p| p.active && p.end_time.is_none())
            .collect()
    }

    /// Get runnable execution pointers (active and not sleeping/waiting)
    pub fn get_runnable_pointers(&self) -> Vec<&ExecutionPointer> {
        let now = Utc::now();
        self.execution_pointers
            .iter()
            .filter(|p| {
                p.active 
                && p.end_time.is_none()
                && p.sleep_until.map_or(true, |sleep| sleep <= now)
                && p.event_name.is_none()
            })
            .collect()
    }

    /// Get execution pointers waiting for events
    pub fn get_waiting_pointers(&self) -> Vec<&ExecutionPointer> {
        self.execution_pointers
            .iter()
            .filter(|p| p.active && p.event_name.is_some() && !p.event_published)
            .collect()
    }

    /// Get execution pointers that are sleeping
    pub fn get_sleeping_pointers(&self) -> Vec<&ExecutionPointer> {
        let now = Utc::now();
        self.execution_pointers
            .iter()
            .filter(|p| {
                p.active 
                && p.sleep_until.map_or(false, |sleep| sleep > now)
            })
            .collect()
    }

    /// Mark workflow as complete
    pub fn mark_complete(&mut self) {
        self.status = WorkflowStatus::Complete;
        self.complete_time = Some(Utc::now());
        
        // Deactivate all execution pointers
        for pointer in &mut self.execution_pointers {
            pointer.active = false;
            if pointer.end_time.is_none() {
                pointer.end_time = Some(Utc::now());
            }
        }
    }

    /// Mark workflow as terminated
    pub fn mark_terminated(&mut self) {
        self.status = WorkflowStatus::Terminated;
        self.complete_time = Some(Utc::now());
        
        // Deactivate all execution pointers
        for pointer in &mut self.execution_pointers {
            pointer.active = false;
            if pointer.end_time.is_none() {
                pointer.end_time = Some(Utc::now());
            }
        }
    }

    /// Suspend the workflow
    pub fn suspend(&mut self) {
        self.status = WorkflowStatus::Suspended;
    }

    /// Resume the workflow
    pub fn resume(&mut self) {
        if self.status == WorkflowStatus::Suspended {
            self.status = WorkflowStatus::Runnable;
        }
    }

    /// Check if workflow is in a final state
    pub fn is_final_state(&self) -> bool {
        matches!(self.status, WorkflowStatus::Complete | WorkflowStatus::Terminated)
    }

    /// Check if workflow can be executed
    pub fn can_execute(&self) -> bool {
        self.status == WorkflowStatus::Runnable && !self.get_runnable_pointers().is_empty()
    }

    /// Get workflow data as a specific type
    pub fn get_data<T>(&self) -> Option<T>
    where
        T: for<'de> Deserialize<'de>,
    {
        self.data
            .as_ref()
            .and_then(|d| serde_json::from_value(d.clone()).ok())
    }

    /// Update workflow data
    pub fn set_data<T>(&mut self, data: T) -> Result<(), serde_json::Error>
    where
        T: Serialize,
    {
        self.data = Some(serde_json::to_value(data)?);
        Ok(())
    }

    /// Calculate the next execution time based on execution pointers
    pub fn calculate_next_execution(&self) -> Option<DateTime<Utc>> {
        let sleeping_times: Vec<DateTime<Utc>> = self
            .execution_pointers
            .iter()
            .filter_map(|p| p.sleep_until)
            .collect();

        sleeping_times.into_iter().min()
    }
}

/// Workflow execution status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum WorkflowStatus {
    /// Workflow can be executed
    Runnable,
    /// Workflow is suspended (manual intervention required)
    Suspended,
    /// Workflow completed successfully
    Complete,
    /// Workflow was terminated (either manually or due to fatal error)
    Terminated,
}

impl Default for WorkflowStatus {
    fn default() -> Self {
        WorkflowStatus::Runnable
    }
}

impl std::fmt::Display for WorkflowStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            WorkflowStatus::Runnable => write!(f, "Runnable"),
            WorkflowStatus::Suspended => write!(f, "Suspended"),
            WorkflowStatus::Complete => write!(f, "Complete"),
            WorkflowStatus::Terminated => write!(f, "Terminated"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_workflow_instance_creation() {
        let instance = WorkflowInstance::new(
            "test_workflow".to_string(),
            1,
            Some(serde_json::json!({"test": "data"})),
        );

        assert_eq!(instance.workflow_definition_id, "test_workflow");
        assert_eq!(instance.version, 1);
        assert_eq!(instance.status, WorkflowStatus::Runnable);
        assert!(instance.correlation_id.is_some());
        assert!(!instance.is_final_state());
    }

    #[test]
    fn test_workflow_instance_with_metadata() {
        let instance = WorkflowInstance::new(
            "test_workflow".to_string(),
            1,
            None,
        )
        .with_description("Test description".to_string())
        .with_reference("REF-123".to_string())
        .with_correlation_id("custom-correlation".to_string());

        assert_eq!(instance.description, Some("Test description".to_string()));
        assert_eq!(instance.reference, Some("REF-123".to_string()));
        assert_eq!(instance.correlation_id, Some("custom-correlation".to_string()));
    }

    #[test]
    fn test_workflow_status_transitions() {
        let mut instance = WorkflowInstance::new(
            "test_workflow".to_string(),
            1,
            None,
        );

        // Test suspend/resume
        instance.suspend();
        assert_eq!(instance.status, WorkflowStatus::Suspended);

        instance.resume();
        assert_eq!(instance.status, WorkflowStatus::Runnable);

        // Test completion
        instance.mark_complete();
        assert_eq!(instance.status, WorkflowStatus::Complete);
        assert!(instance.complete_time.is_some());
        assert!(instance.is_final_state());

        // Resume should not work on completed workflow
        instance.resume();
        assert_eq!(instance.status, WorkflowStatus::Complete);
    }

    #[test]
    fn test_workflow_data_serialization() {
        #[derive(Serialize, Deserialize, PartialEq, Debug)]
        struct TestData {
            name: String,
            value: i32,
        }

        let test_data = TestData {
            name: "test".to_string(),
            value: 42,
        };

        let mut instance = WorkflowInstance::new(
            "test_workflow".to_string(),
            1,
            None,
        );

        instance.set_data(&test_data).unwrap();
        let retrieved_data: TestData = instance.get_data().unwrap();

        assert_eq!(test_data, retrieved_data);
    }

    #[test]
    fn test_workflow_status_display() {
        assert_eq!(format!("{}", WorkflowStatus::Runnable), "Runnable");
        assert_eq!(format!("{}", WorkflowStatus::Suspended), "Suspended");
        assert_eq!(format!("{}", WorkflowStatus::Complete), "Complete");
        assert_eq!(format!("{}", WorkflowStatus::Terminated), "Terminated");
    }
}
