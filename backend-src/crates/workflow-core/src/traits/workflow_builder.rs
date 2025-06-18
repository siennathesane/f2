use crate::traits::step_body::StepBody;
use std::time::Duration;
pub(crate) use crate::{StepExecutionContext, WorkflowDefinition, WorkflowStep};

#[derive(Debug)]
pub enum ExecutionResult {
    // Represents the outcome of a step's execution.
    Ok,
    // Other results like Suspend, Terminate, etc., would go here.
}

#[derive(Debug, Clone, Copy)]
pub enum WorkflowErrorHandling {
    // Defines how to handle errors in a workflow.
    Retry,
    Suspend,
    Terminate,
}

/// A helper trait to allow cloning of `Box<dyn WorkflowBuilder<TData>>`.
/// This is necessary for methods like `create_branch` that need to produce a new builder.
/// You can implement this for any `T: WorkflowBuilder<TData> + Clone`.
pub trait DynClone<TData> {
    fn clone_box(&self) -> Box<dyn WorkflowBuilder<TData>>;
}

impl<T, TData> DynClone<TData> for T
where
    T: 'static + WorkflowBuilder<TData> + Clone,
{
    fn clone_box(&self) -> Box<dyn WorkflowBuilder<TData>> {
        Box::new(self.clone())
    }
}

/// A trait for building and modifying a sequence of steps.
/// This corresponds to `IWorkflowModifier` and parts of `IStepBuilder`.
/// It is designed to be object-safe to allow for dynamic step chaining.
pub trait StepModifier<TData> {
    /// Adds a new step to the sequence using a `StepBody` implementation.
    /// This is the equivalent of the generic `Then<TStep>()` method, using type erasure.
    fn then_step(&mut self, step_body: Box<dyn StepBody>) -> &mut dyn StepModifier<TData>;

    /// Adds a step defined by a closure that returns an `ExecutionResult`.
    /// This is equivalent to `Then(Func<...>)`.
    fn then_fn(
        &mut self,
        body: Box<dyn Fn(&StepExecutionContext, &mut TData) -> ExecutionResult>,
    ) -> &mut dyn StepModifier<TData>;

    /// Adds a step defined by a closure that returns nothing.
    /// This is equivalent to `Then(Action<...>)`.
    fn then_action(
        &mut self,
        body: Box<dyn Fn(&StepExecutionContext, &mut TData)>,
    ) -> &mut dyn StepModifier<TData>;
}

/// The main workflow builder trait, equivalent to `IWorkflowBuilder` and `IWorkflowBuilder<TData>`.
///
/// It requires `DynClone<TData>` and `StepModifier<TData>` as supertraits to support
/// branching and step-chaining with `dyn` trait objects.
///
/// The generic parameter `<TData>` corresponds to the workflow's data type.
pub trait WorkflowBuilder<TData>: DynClone<TData> + StepModifier<TData> {
    // --- Accessors (from IWorkflowBuilder) ---

    /// Returns a slice of the steps currently added to the builder.
    /// Equivalent to the `Steps` property.
    fn steps(&self) -> &[WorkflowStep];

    /// Returns a mutable slice of the steps.
    fn steps_mut(&mut self) -> &mut Vec<WorkflowStep>;

    /// Builds the final, executable workflow definition.
    /// Equivalent to the `Build` method.
    fn build(&self, id: String, version: i32) -> WorkflowDefinition;

    /// Directly adds a pre-constructed `WorkflowStep`.
    /// Equivalent to the `AddStep` method.
    fn add_step(&mut self, step: WorkflowStep);

    // --- Workflow Structure (from IWorkflowBuilder and IWorkflowBuilder<TData>) ---

    /// Attaches the steps from another builder instance.
    /// In Rust, it's safer and simpler to pass the steps directly rather than the builder itself.
    fn attach_branch_steps(&mut self, steps: Vec<WorkflowStep>);

    /// Creates a new, independent builder instance for a parallel branch.
    /// Requires the `DynClone` supertrait to work on a `dyn` object.
    fn create_branch(&self) -> Box<dyn WorkflowBuilder<TData>>;

    // --- Step Definition (from IWorkflowBuilder<TData>) ---
    // These methods replace the overloaded and generic `StartWith` methods.

    /// Starts the workflow with a `StepBody` implementation.
    fn start_with_step(&mut self, step_body: Box<dyn StepBody>) -> &mut dyn StepModifier<TData>;

    /// Starts the workflow with a closure that returns an `ExecutionResult`.
    fn start_with_fn(
        &mut self,
        body: Box<dyn Fn(&StepExecutionContext, &mut TData) -> ExecutionResult>,
    ) -> &mut dyn StepModifier<TData>;

    /// Starts the workflow with a closure that returns nothing.
    fn start_with_action(
        &mut self,
        body: Box<dyn Fn(&StepExecutionContext, &mut TData)>,
    ) -> &mut dyn StepModifier<TData>;

    // --- Configuration (from IWorkflowBuilder<TData>) ---

    /// Configures the default error handling strategy for the workflow.
    /// Note: In a `dyn Trait` context, builder methods typically modify `&mut self`
    /// and return nothing, as returning `&mut Self` is not object-safe.
    fn use_default_error_behavior(
        &mut self,
        behavior: WorkflowErrorHandling,
        retry_interval: Option<Duration>,
    );

    /// Retrieves all steps that are upstream from a given step ID.
    fn get_upstream_steps(&self, id: usize) -> Vec<WorkflowStep>;
}
