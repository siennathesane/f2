pub mod error;
pub mod workflow_instance;
pub mod workflow_step;
pub mod execution_pointer;

// Re-export the enhanced execution_result and event from the root
pub use crate::execution_result::ExecutionResult;
pub use crate::event::{Event, EventSubscription};

// Re-export the new model types
pub use error::{WorkflowError, WorkflowResult};
pub use workflow_instance::{WorkflowInstance, WorkflowStatus};
pub use workflow_step::{WorkflowStep, WorkflowDefinition};
pub use execution_pointer::{ExecutionPointer, PointerStatus};
