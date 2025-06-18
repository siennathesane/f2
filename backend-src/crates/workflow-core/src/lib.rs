//! # Workflow Core
//! 
//! A lightweight, embeddable workflow engine for Rust applications.
//! 
//! This crate provides a flexible workflow execution engine that supports:
//! - Sequential and parallel step execution
//! - Event-driven workflows
//! - Error handling and retry logic
//! - Saga (compensation) patterns
//! - Pluggable persistence providers
//! - gRPC service integration
//! - Distributed execution coordination
//! 
//! ## Quick Start
//! 
//! ```rust,no_run
//! use workflow_core::prelude::*;
//!
//! // Define a simple step
//! #[derive(Debug)]
//! struct HelloWorldStep;
//!
//! #[async_trait::async_trait]
//! impl StepBody for HelloWorldStep {
//!     async fn run(&self, _context: &StepExecutionContext) -> WorkflowResult<ExecutionResult> {
//!         println!("Hello, World!");
//!         Ok(ExecutionResult::next())
//!     }
//! }
//!
//! // Define a workflow
//! #[derive(Debug)]
//! struct HelloWorldWorkflow;
//!
//! impl Workflow<()> for HelloWorldWorkflow {
//!     fn id(&self) -> &str { "hello_world" }
//!     fn version(&self) -> i32 { 1 }
//!     
//!     fn build(&self, builder: &mut dyn WorkflowBuilder<()>) -> WorkflowResult<()> {
//!         // Implementation would use the builder API
//!         Ok(())
//!     }
//! }
//! ```
//! 
//! ## Features
//! 
//! - **Type Safety**: Strongly typed workflow data and step interfaces
//! - **Async/Await**: Full async support with tokio integration
//! - **Error Handling**: Comprehensive error types and retry mechanisms
//! - **Persistence**: Pluggable persistence providers (PostgreSQL, etc.)
//! - **Events**: Event-driven workflow triggering and coordination
//! - **Distributed**: Support for distributed execution across multiple nodes
//! - **Observability**: Built-in logging, tracing, and metrics
//! - **gRPC Integration**: First-class support for gRPC service calls

pub mod traits;
pub mod models;
pub mod execution_result;
pub mod event;
pub mod execution;
pub mod builder;
pub mod persistence;
pub mod host;

// Re-export commonly used types for convenience
pub use traits::{
    StepBody, StepExecutionContext,
    Workflow, UntypedWorkflow, ErrorBehavior, RetryPolicy,
    WorkflowHost, WorkflowBuilder,
    PersistenceProvider, WorkflowExecutor,
};

pub use models::{
    WorkflowError, WorkflowResult,
    WorkflowInstance, WorkflowStatus,
    WorkflowStep, WorkflowDefinition,
    ExecutionPointer, PointerStatus,
    ExecutionResult, Event, EventSubscription,
};

/// Prelude module for convenient imports
pub mod prelude {
    pub use crate::traits::{
        StepBody, StepExecutionContext,
        Workflow, UntypedWorkflow, ErrorBehavior, RetryPolicy,
        WorkflowHost, WorkflowBuilder,
        PersistenceProvider, WorkflowExecutor,
    };

    pub use crate::models::{
        WorkflowError, WorkflowResult,
        WorkflowInstance, WorkflowStatus,
        WorkflowStep, WorkflowDefinition,
        ExecutionPointer, PointerStatus,
    };

    pub use crate::execution_result::ExecutionResult;
    pub use crate::event::{Event, EventSubscription};

    // Re-export async_trait for convenience
    pub use async_trait::async_trait;
    
    // Re-export common types
    pub use uuid::Uuid;
    pub use chrono::{DateTime, Utc};
    pub use serde::{Serialize, Deserialize};
    pub use serde_json;
}

/// Helper macro for creating simple workflow steps
/// 
/// This macro simplifies the creation of inline workflow steps for simple operations.
/// 
/// # Example
/// 
/// ```rust,no_run
/// use workflow_core::prelude::*;///
///
/// use workflow_core::simple_step;
///
/// simple_step!(LogStep, |context| async move {
///     println!("Processing step: {}", context.step_name);
///     Ok(ExecutionResult::next())
/// });
/// ```
#[macro_export]
macro_rules! simple_step {
    ($name:ident, $body:expr) => {
        #[derive(Debug, Clone)]
        pub struct $name;

        #[async_trait::async_trait]
        impl $crate::traits::StepBody for $name {
            async fn run(
                &self,
                context: &$crate::traits::StepExecutionContext,
            ) -> $crate::models::WorkflowResult<$crate::ExecutionResult> {
                let closure: fn(&$crate::traits::StepExecutionContext) 
                    -> std::pin::Pin<Box<dyn std::future::Future<Output = $crate::models::WorkflowResult<$crate::ExecutionResult>> + Send + '_>> = $body;
                closure(context).await
            }
            
            fn name(&self) -> &str {
                stringify!($name)
            }
        }
    };
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::prelude::*;

    #[test]
    fn test_simple_step_macro() {
        simple_step!(TestStep, |_context| async move {
            Ok(ExecutionResult::next())
        });

        let step = TestStep;
        assert_eq!(step.name(), "TestStep");
    }

    #[test]
    fn test_prelude_imports() {
        // Test that we can use types from prelude
        let _id = Uuid::new_v4();
        let _now = Utc::now();
        let _status = WorkflowStatus::Runnable;
        let _result = ExecutionResult::next();
    }

    #[test]
    fn test_error_types() {
        let error = WorkflowError::ConfigurationError("test error".to_string());
        assert!(!error.should_retry());
        
        let result: WorkflowResult<()> = Err(error);
        assert!(result.is_err());
    }

    #[test]
    fn test_execution_result_creation() {
        let result1 = ExecutionResult::next();
        assert!(result1.proceed);
        
        let result2 = ExecutionResult::outcome("success");
        assert!(result2.proceed);
        
        let result3 = ExecutionResult::sleep(
            std::time::Duration::from_secs(60), 
            Some("sleeping")
        );
        assert!(!result3.proceed);
        assert!(result3.is_sleeping());
    }
}
