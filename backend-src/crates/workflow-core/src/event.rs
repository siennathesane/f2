use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Workflow event for triggering and coordinating workflow execution
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Event {
    /// Unique event identifier
    pub id: Uuid,
    
    /// Event type/name for filtering
    pub name: String,
    
    /// Event key for targeting specific workflows/steps
    pub key: Option<String>,
    
    /// Event payload data
    pub data: Option<serde_json::Value>,
    
    /// When the event occurred
    pub time: DateTime<Utc>,
}

impl Event {
    /// Constant for activity events
    pub const EVENT_TYPE_ACTIVITY: &'static str = "workflow_core.activity";

    /// Create a new event with required fields
    pub fn new(name: String, key: Option<String>) -> Self {
        Self {
            id: Uuid::new_v4(),
            name,
            key,
            data: None,
            time: Utc::now(),
        }
    }

    /// Create event with data payload
    pub fn with_data<T: Serialize>(
        name: String, 
        key: Option<String>, 
        data: T
    ) -> Self {
        Self {
            id: Uuid::new_v4(),
            name,
            key,
            data: serde_json::to_value(data).ok(),
            time: Utc::now(),
        }
    }

    /// Create event targeting a specific workflow  
    pub fn for_workflow(
        name: String,
        key: Option<String>
    ) -> Self {
        Self {
            id: Uuid::new_v4(),
            name,
            key,
            data: None,
            time: Utc::now(),
        }
    }

    /// Set event data
    pub fn with_event_data(mut self, data: serde_json::Value) -> Self {
        self.data = Some(data);
        self
    }

    /// Get event data as a specific type
    pub fn get_data<T: for<'de> Deserialize<'de>>(&self) -> Option<T> {
        self.data
            .as_ref()
            .and_then(|d| serde_json::from_value(d.clone()).ok())
    }

    /// Check if event matches criteria
    pub fn matches(&self, event_name: &str, event_key: Option<&str>) -> bool {
        if self.name != event_name {
            return false;
        }
        
        match (event_key, &self.key) {
            (Some(expected_key), Some(actual_key)) => expected_key == actual_key,
            (None, _) => true,
            (Some(_), None) => false,
        }
    }

    /// Check if event is expired based on age
    pub fn is_expired(&self, max_age: chrono::Duration) -> bool {
        let now = Utc::now();
        now.signed_duration_since(self.time) > max_age
    }
}

impl Default for Event {
    fn default() -> Self {
        Self::new("default".to_string(), Some("default".to_string()))
    }
}

/// Event subscription for waiting workflows
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventSubscription {
    /// Unique subscription identifier
    pub id: Uuid,
    
    /// Which workflow instance is subscribed
    pub workflow_id: Uuid,
    
    /// Which step is waiting
    pub step_id: i32,
    
    /// Event name to listen for
    pub event_name: String,
    
    /// Event key to filter on (optional)
    pub event_key: Option<String>,
    
    /// When subscription was created
    pub subscribe_as_of: DateTime<Utc>,
    
    /// Additional subscription data
    pub subscription_data: Option<serde_json::Value>,
    
    /// External token for authentication
    pub external_token: Option<String>,
    
    /// External worker ID
    pub external_worker_id: Option<String>,
    
    /// When external token expires
    pub external_token_expiry: Option<DateTime<Utc>>,
}

impl EventSubscription {
    pub fn new(
        workflow_id: Uuid,
        step_id: i32,
        event_name: String,
        event_key: Option<String>
    ) -> Self {
        Self {
            id: Uuid::new_v4(),
            workflow_id,
            step_id,
            event_name,
            event_key,
            subscribe_as_of: Utc::now(),
            subscription_data: None,
            external_token: None,
            external_worker_id: None,
            external_token_expiry: None,
        }
    }

    /// Check if this subscription matches an event
    pub fn matches_event(&self, event: &Event) -> bool {
        if self.event_name != event.name {
            return false;
        }

        match (&self.event_key, &event.key) {
            (Some(sub_key), Some(event_key)) => sub_key == event_key,
            (None, _) => true,
            (Some(_), None) => false,
        }
    }
    
    /// Set external authentication token
    pub fn with_external_token(mut self, token: String, worker_id: String, expiry: DateTime<Utc>) -> Self {
        self.external_token = Some(token);
        self.external_worker_id = Some(worker_id);
        self.external_token_expiry = Some(expiry);
        self
    }
    
    /// Check if external token is expired
    pub fn is_token_expired(&self) -> bool {
        match self.external_token_expiry {
            Some(expiry) => Utc::now() > expiry,
            None => false,
        }
    }
}



#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_event_creation() {
        let event = Event::new("test_event".to_string(), Some("test_key".to_string()));
        assert_eq!(event.name, "test_event");
        assert_eq!(event.key, Some("test_key".to_string()));
    }

    #[test]
    fn test_event_with_data() {
        let data = json!({"message": "hello"});
        let event = Event::with_data(
            "test_event".to_string(),
            Some("test_key".to_string()),
            data.clone()
        );
        assert_eq!(event.data, Some(data));
    }

    #[test]
    fn test_event_matches() {
        let event = Event::new("user_action".to_string(), Some("user_123".to_string()));
        
        assert!(event.matches("user_action", Some("user_123")));
        assert!(event.matches("user_action", None));
        assert!(!event.matches("other_event", Some("user_123")));
        assert!(!event.matches("user_action", Some("user_456")));
    }

    #[test]
    fn test_subscription_matches_event() {
        let subscription = EventSubscription::new(
            Uuid::new_v4(),
            1,
            "user_action".to_string(),
            Some("user_123".to_string())
        );

        let matching_event = Event::new("user_action".to_string(), Some("user_123".to_string()));
        let non_matching_event = Event::new("other_event".to_string(), Some("user_123".to_string()));

        assert!(subscription.matches_event(&matching_event));
        assert!(!subscription.matches_event(&non_matching_event));
    }

    #[test]
    fn test_event_expiration() {
        let mut event = Event::new("test_event".to_string(), Some("test_key".to_string()));
        
        // Set event time to 2 hours ago
        event.time = Utc::now() - chrono::Duration::hours(2);
        
        // Check if event is expired with 1 hour max age
        assert!(event.is_expired(chrono::Duration::hours(1)));
        
        // Check if event is not expired with 3 hour max age
        assert!(!event.is_expired(chrono::Duration::hours(3)));
    }
}
