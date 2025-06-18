use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use std::collections::HashMap;

/// Execution pointer tracks the state of a specific step within a workflow instance
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionPointer {
    /// Unique identifier for this execution pointer
    pub id: Uuid,
    
    /// ID of the step this pointer is executing
    pub step_id: i32,
    
    /// Whether this pointer is currently active
    pub active: bool,
    
    /// Time when this pointer should wake up from sleep
    pub sleep_until: Option<DateTime<Utc>>,
    
    /// Data that should be persisted between step executions
    pub persistence_data: Option<serde_json::Value>,
    
    /// When this pointer started executing
    pub start_time: Option<DateTime<Utc>>,
    
    /// When this pointer finished executing
    pub end_time: Option<DateTime<Utc>>,
    
    /// Event name this pointer is waiting for
    pub event_name: Option<String>,
    
    /// Event key for filtering specific events
    pub event_key: Option<String>,
    
    /// Whether the event has been published for this pointer
    pub event_published: bool,
    
    /// Data received from the event
    pub event_data: Option<serde_json::Value>,
    
    /// Additional attributes for extensibility
    pub extension_attributes: HashMap<String, serde_json::Value>,
    
    /// Name of the step (for debugging/logging)
    pub step_name: Option<String>,
    
    /// Number of retry attempts for this step
    pub retry_count: i32,
    
    /// Child execution pointer IDs (for parallel execution)
    pub children: Vec<Uuid>,
    
    /// Context item for this execution
    pub context_item: Option<serde_json::Value>,
    
    /// ID of the predecessor execution pointer
    pub predecessor_id: Option<Uuid>,
    
    /// Outcome value from step execution
    pub outcome: Option<serde_json::Value>,
    
    /// Current status of this execution pointer
    pub status: PointerStatus,
    
    /// Scope for hierarchical execution (branches, loops, etc.)
    pub scope: Vec<String>,
    
    /// Correlation ID for tracing
    pub correlation_id: Option<String>,
}

impl ExecutionPointer {
    /// Create a new execution pointer for a step
    pub fn new(step_id: i32, step_name: Option<String>) -> Self {
        Self {
            id: Uuid::new_v4(),
            step_id,
            active: true,
            sleep_until: None,
            persistence_data: None,
            start_time: None,
            end_time: None,
            event_name: None,
            event_key: None,
            event_published: false,
            event_data: None,
            extension_attributes: HashMap::new(),
            step_name,
            retry_count: 0,
            children: Vec::new(),
            context_item: None,
            predecessor_id: None,
            outcome: None,
            status: PointerStatus::Pending,
            scope: Vec::new(),
            correlation_id: None,
        }
    }

    /// Create execution pointer with specific ID
    pub fn with_id(id: Uuid, step_id: i32, step_name: Option<String>) -> Self {
        Self {
            id,
            step_id,
            active: true,
            sleep_until: None,
            persistence_data: None,
            start_time: None,
            end_time: None,
            event_name: None,
            event_key: None,
            event_published: false,
            event_data: None,
            extension_attributes: HashMap::new(),
            step_name,
            retry_count: 0,
            children: Vec::new(),
            context_item: None,
            predecessor_id: None,
            outcome: None,
            status: PointerStatus::Pending,
            scope: Vec::new(),
            correlation_id: None,
        }
    }

    /// Set the scope for this execution pointer
    pub fn with_scope(mut self, scope: Vec<String>) -> Self {
        self.scope = scope;
        self
    }

    /// Set the predecessor for this execution pointer
    pub fn with_predecessor(mut self, predecessor_id: Uuid) -> Self {
        self.predecessor_id = Some(predecessor_id);
        self
    }

    /// Set correlation ID
    pub fn with_correlation_id(mut self, correlation_id: String) -> Self {
        self.correlation_id = Some(correlation_id);
        self
    }

    /// Mark this pointer as started
    pub fn mark_started(&mut self) {
        self.status = PointerStatus::Running;
        self.start_time = Some(Utc::now());
    }

    /// Mark this pointer as completed with an outcome
    pub fn mark_completed(&mut self, outcome: Option<serde_json::Value>) {
        self.status = PointerStatus::Complete;
        self.end_time = Some(Utc::now());
        self.outcome = outcome;
        self.active = false;
    }

    /// Mark this pointer as failed
    pub fn mark_failed(&mut self) {
        self.status = PointerStatus::Failed;
        self.end_time = Some(Utc::now());
        self.active = false;
    }

    /// Mark this pointer as sleeping until a specific time
    pub fn mark_sleeping(&mut self, until: DateTime<Utc>, persistence_data: Option<serde_json::Value>) {
        self.status = PointerStatus::Sleeping;
        self.sleep_until = Some(until);
        self.persistence_data = persistence_data;
    }

    /// Mark this pointer as waiting for an event
    pub fn mark_waiting_for_event(
        &mut self,
        event_name: String,
        event_key: Option<String>,
        persistence_data: Option<serde_json::Value>,
    ) {
        self.status = PointerStatus::WaitingForEvent;
        self.event_name = Some(event_name);
        self.event_key = event_key;
        self.event_published = false;
        self.persistence_data = persistence_data;
    }

    /// Mark this pointer as cancelled
    pub fn mark_cancelled(&mut self) {
        self.status = PointerStatus::Cancelled;
        self.end_time = Some(Utc::now());
        self.active = false;
    }

    /// Increment retry count
    pub fn increment_retry(&mut self) {
        self.retry_count += 1;
    }

    /// Reset for retry (clear end time, set status back to pending)
    pub fn reset_for_retry(&mut self) {
        self.status = PointerStatus::Pending;
        self.end_time = None;
        self.active = true;
    }

    /// Add a child execution pointer
    pub fn add_child(&mut self, child_id: Uuid) {
        if !self.children.contains(&child_id) {
            self.children.push(child_id);
        }
    }

    /// Remove a child execution pointer
    pub fn remove_child(&mut self, child_id: Uuid) {
        self.children.retain(|id| *id != child_id);
    }

    /// Check if this pointer is runnable
    pub fn is_runnable(&self) -> bool {
        self.active 
            && self.status == PointerStatus::Pending
            && self.sleep_until.map_or(true, |sleep| sleep <= Utc::now())
            && self.event_name.is_none()
    }

    /// Check if this pointer is waiting for an event
    pub fn is_waiting_for_event(&self) -> bool {
        self.active && self.status == PointerStatus::WaitingForEvent
    }

    /// Check if this pointer is sleeping
    pub fn is_sleeping(&self) -> bool {
        self.active 
            && self.status == PointerStatus::Sleeping
            && self.sleep_until.map_or(false, |sleep| sleep > Utc::now())
    }

    /// Check if this pointer is in a final state
    pub fn is_final(&self) -> bool {
        matches!(
            self.status,
            PointerStatus::Complete | PointerStatus::Failed | PointerStatus::Cancelled
        )
    }

    /// Get execution duration if completed
    pub fn execution_duration(&self) -> Option<chrono::Duration> {
        match (self.start_time, self.end_time) {
            (Some(start), Some(end)) => Some(end.signed_duration_since(start)),
            _ => None,
        }
    }

    /// Set an extension attribute
    pub fn set_extension_attribute<T: Serialize>(&mut self, key: String, value: T) -> Result<(), serde_json::Error> {
        self.extension_attributes.insert(key, serde_json::to_value(value)?);
        Ok(())
    }

    /// Get an extension attribute
    pub fn get_extension_attribute<T>(&self, key: &str) -> Option<T>
    where
        T: for<'de> Deserialize<'de>,
    {
        self.extension_attributes
            .get(key)
            .and_then(|v| serde_json::from_value(v.clone()).ok())
    }

    /// Get persistence data as a specific type
    pub fn get_persistence_data<T>(&self) -> Option<T>
    where
        T: for<'de> Deserialize<'de>,
    {
        self.persistence_data
            .as_ref()
            .and_then(|d| serde_json::from_value(d.clone()).ok())
    }

    /// Set persistence data
    pub fn set_persistence_data<T: Serialize>(&mut self, data: T) -> Result<(), serde_json::Error> {
        self.persistence_data = Some(serde_json::to_value(data)?);
        Ok(())
    }

    /// Get outcome as a specific type
    pub fn get_outcome<T>(&self) -> Option<T>
    where
        T: for<'de> Deserialize<'de>,
    {
        self.outcome
            .as_ref()
            .and_then(|o| serde_json::from_value(o.clone()).ok())
    }

    /// Get event data as a specific type
    pub fn get_event_data<T>(&self) -> Option<T>
    where
        T: for<'de> Deserialize<'de>,
    {
        self.event_data
            .as_ref()
            .and_then(|d| serde_json::from_value(d.clone()).ok())
    }

    /// Process an event for this pointer
    pub fn process_event(&mut self, event_data: Option<serde_json::Value>) -> bool {
        if self.is_waiting_for_event() && !self.event_published {
            self.event_data = event_data;
            self.event_published = true;
            self.status = PointerStatus::Pending; // Ready to run again
            true
        } else {
            false
        }
    }
}

/// Status of an execution pointer
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum PointerStatus {
    /// Pointer is pending execution
    Pending,
    /// Pointer is currently running
    Running,
    /// Pointer completed successfully
    Complete,
    /// Pointer is sleeping/delayed
    Sleeping,
    /// Pointer is waiting for an external event
    WaitingForEvent,
    /// Pointer failed execution
    Failed,
    /// Pointer was compensated (saga pattern)
    Compensated,
    /// Pointer was cancelled
    Cancelled,
    /// Pointer is waiting for predecessor to complete
    PendingPredecessor,
}

impl Default for PointerStatus {
    fn default() -> Self {
        PointerStatus::Pending
    }
}

impl std::fmt::Display for PointerStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PointerStatus::Pending => write!(f, "Pending"),
            PointerStatus::Running => write!(f, "Running"),
            PointerStatus::Complete => write!(f, "Complete"),
            PointerStatus::Sleeping => write!(f, "Sleeping"),
            PointerStatus::WaitingForEvent => write!(f, "WaitingForEvent"),
            PointerStatus::Failed => write!(f, "Failed"),
            PointerStatus::Compensated => write!(f, "Compensated"),
            PointerStatus::Cancelled => write!(f, "Cancelled"),
            PointerStatus::PendingPredecessor => write!(f, "PendingPredecessor"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_execution_pointer_creation() {
        let pointer = ExecutionPointer::new(1, Some("test_step".to_string()));
        
        assert_eq!(pointer.step_id, 1);
        assert_eq!(pointer.step_name, Some("test_step".to_string()));
        assert_eq!(pointer.status, PointerStatus::Pending);
        assert!(pointer.active);
        assert_eq!(pointer.retry_count, 0);
    }

    #[test]
    fn test_execution_pointer_state_transitions() {
        let mut pointer = ExecutionPointer::new(1, Some("test_step".to_string()));
        
        // Start execution
        pointer.mark_started();
        assert_eq!(pointer.status, PointerStatus::Running);
        assert!(pointer.start_time.is_some());
        
        // Complete execution
        pointer.mark_completed(Some(json!({"result": "success"})));
        assert_eq!(pointer.status, PointerStatus::Complete);
        assert!(pointer.end_time.is_some());
        assert!(!pointer.active);
        assert!(pointer.is_final());
        
        let duration = pointer.execution_duration().unwrap();
        assert!(duration.num_milliseconds() >= 0);
    }

    #[test]
    fn test_execution_pointer_sleeping() {
        let mut pointer = ExecutionPointer::new(1, Some("test_step".to_string()));
        let sleep_until = Utc::now() + chrono::Duration::minutes(5);
        
        pointer.mark_sleeping(sleep_until, Some(json!({"sleep_data": "test"})));
        
        assert_eq!(pointer.status, PointerStatus::Sleeping);
        assert_eq!(pointer.sleep_until, Some(sleep_until));
        assert!(pointer.is_sleeping());
        assert!(!pointer.is_runnable());
    }

    #[test]
    fn test_execution_pointer_event_waiting() {
        let mut pointer = ExecutionPointer::new(1, Some("test_step".to_string()));
        
        pointer.mark_waiting_for_event(
            "user_input".to_string(),
            Some("user_123".to_string()),
            Some(json!({"context": "waiting"})),
        );
        
        assert_eq!(pointer.status, PointerStatus::WaitingForEvent);
        assert_eq!(pointer.event_name, Some("user_input".to_string()));
        assert_eq!(pointer.event_key, Some("user_123".to_string()));
        assert!(pointer.is_waiting_for_event());
        assert!(!pointer.event_published);
        
        // Process event
        let event_processed = pointer.process_event(Some(json!({"user_choice": "yes"})));
        assert!(event_processed);
        assert!(pointer.event_published);
        assert_eq!(pointer.status, PointerStatus::Pending);
    }

    #[test]
    fn test_execution_pointer_retry() {
        let mut pointer = ExecutionPointer::new(1, Some("test_step".to_string()));
        
        pointer.mark_started();
        pointer.mark_failed();
        assert_eq!(pointer.status, PointerStatus::Failed);
        assert!(!pointer.active);
        
        // Reset for retry
        pointer.increment_retry();
        pointer.reset_for_retry();
        
        assert_eq!(pointer.retry_count, 1);
        assert_eq!(pointer.status, PointerStatus::Pending);
        assert!(pointer.active);
        assert!(pointer.end_time.is_none());
    }

    #[test]
    fn test_execution_pointer_children() {
        let mut pointer = ExecutionPointer::new(1, Some("parent_step".to_string()));
        let child1_id = Uuid::new_v4();
        let child2_id = Uuid::new_v4();
        
        pointer.add_child(child1_id);
        pointer.add_child(child2_id);
        pointer.add_child(child1_id); // Should not duplicate
        
        assert_eq!(pointer.children.len(), 2);
        assert!(pointer.children.contains(&child1_id));
        assert!(pointer.children.contains(&child2_id));
        
        pointer.remove_child(child1_id);
        assert_eq!(pointer.children.len(), 1);
        assert!(!pointer.children.contains(&child1_id));
    }

    #[test]
    fn test_execution_pointer_extension_attributes() {
        let mut pointer = ExecutionPointer::new(1, Some("test_step".to_string()));
        
        #[derive(Serialize, Deserialize, PartialEq, Debug)]
        struct CustomData {
            value: i32,
            name: String,
        }
        
        let custom_data = CustomData {
            value: 42,
            name: "test".to_string(),
        };
        
        pointer.set_extension_attribute("custom".to_string(), &custom_data).unwrap();
        let retrieved_data: CustomData = pointer.get_extension_attribute("custom").unwrap();
        
        assert_eq!(custom_data, retrieved_data);
    }

    #[test]
    fn test_pointer_status_display() {
        assert_eq!(format!("{}", PointerStatus::Pending), "Pending");
        assert_eq!(format!("{}", PointerStatus::Running), "Running");
        assert_eq!(format!("{}", PointerStatus::Complete), "Complete");
        assert_eq!(format!("{}", PointerStatus::WaitingForEvent), "WaitingForEvent");
    }
}
