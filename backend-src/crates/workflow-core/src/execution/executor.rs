use crate::execution_result::ExecutionResult;
use crate::models::error::{WorkflowResult, WorkflowError};
use crate::traits::persistence::{ExecutionPointerData, WorkflowInstanceData, WorkflowInstanceStatus, ExecutionPointerStatus};
use crate::traits::{
    ExecutionAction, ExecutionSummary, StepBody, StepExecutionContext,
    WorkflowExecutor, PersistenceProvider,
};
use async_trait::async_trait;
use std::sync::Arc;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use crate::WorkflowDefinition;

/// Configuration for the workflow executor
#[derive(Debug, Clone)]
pub struct ExecutorConfig {
    /// Maximum execution time for a single step
    pub step_timeout: std::time::Duration,

    /// Maximum total execution time for a workflow
    pub workflow_timeout: std::time::Duration,

    /// Maximum number of concurrent steps
    pub max_concurrency: u32,

    /// Whether to enable compensation on failure
    pub enable_compensation: bool,
}

impl Default for ExecutorConfig {
    fn default() -> Self {
        Self {
            step_timeout: std::time::Duration::from_secs(300), // 5 minutes
            workflow_timeout: std::time::Duration::from_secs(3600), // 1 hour
            max_concurrency: 10,
            enable_compensation: true,
        }
    }
}

/// Basic implementation of the workflow executor
#[derive(Debug)]
pub struct BasicWorkflowExecutor {
    /// Configuration for the executor
    pub config: ExecutorConfig,
}

impl BasicWorkflowExecutor {
    /// Create a new workflow executor with default configuration
    pub fn new() -> Self {
        Self {
            config: ExecutorConfig::default(),
        }
    }

    /// Create a new workflow executor with custom configuration
    pub fn with_config(config: ExecutorConfig) -> Self {
        Self { config }
    }
}

impl Default for BasicWorkflowExecutor {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl WorkflowExecutor for BasicWorkflowExecutor {
    async fn execute_workflow(
        &self,
        instance: &mut WorkflowInstanceData,
    ) -> WorkflowResult<ExecutionSummary> {
        let start_time = std::time::Instant::now();

        // This is a basic stub implementation
        // A full implementation would:
        // 1. Get runnable execution pointers
        // 2. Execute each step
        // 3. Process results and update state
        // 4. Handle errors and retries
        // 5. Determine next execution time

        tracing::info!(
            workflow_id = %instance.id,
            "Starting workflow execution"
        );

        let summary = ExecutionSummary {
            workflow_id: instance.id,
            steps_executed: 0,
            steps_failed: 0,
            steps_waiting: 0,
            workflow_completed: false,
            workflow_failed: false,
            actions: Vec::new(),
            next_execution: None,
            duration: start_time.elapsed(),
            errors: Vec::new(),
        };

        Ok(summary)
    }

    async fn execute_step(
        &self,
        context: &StepExecutionContext,
        step_body: Arc<dyn StepBody>,
    ) -> WorkflowResult<ExecutionResult> {
        tracing::info!(
            step_name = %context.step_name,
            correlation_id = %context.correlation_id,
            "Executing step"
        );

        // Execute the step with timeout
        let result = tokio::time::timeout(self.config.step_timeout, step_body.run(context)).await;

        match result {
            Ok(step_result) => step_result,
            Err(_) => {
                let error = crate::models::error::WorkflowError::StepExecutionFailed {
                    step_name: context.step_name.clone(),
                    reason: "Step execution timeout".to_string(),
                };
                Err(error)
            }
        }
    }

    async fn process_execution_result(
        &self,
        _instance: &mut WorkflowInstanceData,
        _pointer: &mut ExecutionPointerData,
        _result: ExecutionResult,
    ) -> WorkflowResult<Vec<ExecutionAction>> {
        // This is a stub implementation
        // A full implementation would:
        // 1. Update execution pointer based on result
        // 2. Create new execution pointers for next steps
        // 3. Handle branching and parallel execution
        // 4. Schedule future executions
        // 5. Create event subscriptions

        Ok(Vec::new())
    }

    async fn calculate_next_execution(
        &self,
        _instance: &WorkflowInstanceData,
    ) -> WorkflowResult<Option<chrono::DateTime<chrono::Utc>>> {
        // This is a stub implementation
        // A full implementation would:
        // 1. Check all execution pointers
        // 2. Find the earliest sleep_until time
        // 3. Consider scheduled events

        Ok(None)
    }

    fn is_workflow_complete(&self, _instance: &WorkflowInstanceData) -> bool {
        // This is a stub implementation
        // A full implementation would check if all execution pointers are complete
        false
    }

    async fn complete_workflow(&self, instance: &mut WorkflowInstanceData) -> WorkflowResult<()> {
        tracing::info!(
            workflow_id = %instance.id,
            "Completing workflow"
        );

        instance.status = crate::traits::persistence::WorkflowInstanceStatus::Complete;
        instance.complete_time = Some(chrono::Utc::now());

        Ok(())
    }

    async fn fail_workflow(
        &self,
        instance: &mut WorkflowInstanceData,
        error: &crate::models::error::WorkflowError,
    ) -> WorkflowResult<()> {
        tracing::error!(
            workflow_id = %instance.id,
            error = %error,
            "Failing workflow"
        );

        instance.status = crate::traits::persistence::WorkflowInstanceStatus::Terminated;
        instance.complete_time = Some(chrono::Utc::now());

        Ok(())
    }

    async fn should_retry_step(
        &self,
        pointer: &ExecutionPointerData,
        error: &crate::models::error::WorkflowError,
    ) -> WorkflowResult<bool> {
        // Basic retry logic based on error classification
        if !error.should_retry() {
            return Ok(false);
        }

        // Check if we've exceeded max retries (default to 3)
        let max_retries = 3;
        Ok(pointer.retry_count < max_retries)
    }

    fn calculate_retry_delay(
        &self,
        pointer: &ExecutionPointerData,
        error: &crate::models::error::WorkflowError,
    ) -> std::time::Duration {
        // Basic exponential backoff
        let base_delay = error.retry_delay();
        let multiplier = 2_u32.pow(pointer.retry_count as u32);
        let delay = base_delay * multiplier;

        // Cap at 5 minutes
        std::cmp::min(delay, std::time::Duration::from_secs(300))
    }

    async fn get_workflow_definition(
        &self,
        _workflow_id: &str,
        _version: i32,
    ) -> WorkflowResult<Arc<WorkflowDefinition>> {
        // This is a stub implementation
        // A full implementation would retrieve the definition from a registry
        Err(
            crate::models::error::WorkflowError::WorkflowDefinitionNotFound {
                id: "not_implemented".to_string(),
            },
        )
    }

    async fn validate_instance(&self, instance: &WorkflowInstanceData) -> WorkflowResult<()> {
        // Basic validation
        if instance.workflow_definition_id.is_empty() {
            return Err(
                crate::models::error::WorkflowError::InvalidWorkflowDefinition {
                    reason: "Workflow definition ID is empty".to_string(),
                },
            );
        }

        if instance.version <= 0 {
            return Err(
                crate::models::error::WorkflowError::InvalidWorkflowDefinition {
                    reason: "Workflow version must be positive".to_string(),
                },
            );
        }

        Ok(())
    }
}

/// Registry for workflow definitions
#[async_trait]
pub trait WorkflowDefinitionRegistry: Send + Sync {
    async fn get_definition(&self, id: &str, version: i32) -> WorkflowResult<Arc<WorkflowDefinition>>;
    async fn register_definition(&self, definition: WorkflowDefinition) -> WorkflowResult<()>;
    async fn list_definitions(&self) -> WorkflowResult<Vec<WorkflowDefinition>>;
}

/// In-memory workflow definition registry
#[derive(Debug, Default)]
pub struct InMemoryDefinitionRegistry {
    definitions: std::sync::RwLock<std::collections::HashMap<(String, i32), Arc<WorkflowDefinition>>>,
}

impl InMemoryDefinitionRegistry {
    pub fn new() -> Self {
        Self::default()
    }
}

#[async_trait]
impl WorkflowDefinitionRegistry for InMemoryDefinitionRegistry {
    async fn get_definition(&self, id: &str, version: i32) -> WorkflowResult<Arc<WorkflowDefinition>> {
        let definitions = self.definitions.read().unwrap();
        definitions
            .get(&(id.to_string(), version))
            .cloned()
            .ok_or_else(|| WorkflowError::WorkflowDefinitionNotFound {
                id: format!("{}:v{}", id, version),
            })
    }

    async fn register_definition(&self, definition: WorkflowDefinition) -> WorkflowResult<()> {
        let mut definitions = self.definitions.write().unwrap();
        let key = (definition.id.clone(), definition.version);
        definitions.insert(key, Arc::new(definition));
        Ok(())
    }

    async fn list_definitions(&self) -> WorkflowResult<Vec<WorkflowDefinition>> {
        let definitions = self.definitions.read().unwrap();
        Ok(definitions.values().map(|def| (**def).clone()).collect())
    }
}

/// Enhanced implementation of the workflow executor
pub struct EnhancedWorkflowExecutor {
    /// Configuration for the executor
    pub config: ExecutorConfig,
    /// Persistence provider for storing workflow state
    pub persistence: Arc<dyn PersistenceProvider>,
    /// Workflow definition registry
    pub definitions: Arc<dyn WorkflowDefinitionRegistry>,
}

impl EnhancedWorkflowExecutor {
    /// Create a new workflow executor
    pub fn new(
        config: ExecutorConfig,
        persistence: Arc<dyn PersistenceProvider>,
        definitions: Arc<dyn WorkflowDefinitionRegistry>,
    ) -> Self {
        Self {
            config,
            persistence,
            definitions,
        }
    }

    /// Get all runnable execution pointers for a workflow instance
    async fn get_runnable_pointers(
        &self,
        instance: &WorkflowInstanceData,
    ) -> WorkflowResult<Vec<ExecutionPointerData>> {
        let all_pointers = self.persistence.get_execution_pointers(instance.id).await?;
        
        let runnable_pointers: Vec<_> = all_pointers
            .into_iter()
            .filter(|pointer| {
                match pointer.status {
                    ExecutionPointerStatus::WaitingForEvent => {
                        // Check if the event we're waiting for has occurred
                        false // TODO: Implement event checking
                    }
                    ExecutionPointerStatus::Sleeping => {
                        // Check if sleep time has elapsed
                        pointer.sleep_until
                            .map(|sleep_until| Utc::now() >= sleep_until)
                            .unwrap_or(true)
                    }
                    ExecutionPointerStatus::Runnable => true,
                    _ => false,
                }
            })
            .collect();

        Ok(runnable_pointers)
    }

    /// Process outcomes from a step execution result
    fn process_step_outcomes(
        &self,
        definition: &WorkflowDefinition,
        current_step_id: i32,
        result: &ExecutionResult,
    ) -> WorkflowResult<Vec<i32>> {
        let step_def = definition.steps
            .iter()
            .find(|s| s.id == current_step_id)
            .ok_or_else(|| WorkflowError::StepNotFound {
                step_id: current_step_id,
                workflow_id: definition.id.clone(),
            })?;

        let mut next_steps = Vec::new();

        if step_def.outcomes.is_empty() {
            // No explicit outcomes - find the next step in sequence
            if let Some(next_step) = definition.steps
                .iter()
                .find(|s| s.id == current_step_id + 1) 
            {
                next_steps.push(next_step.id);
            }
        } else {
            // Process explicit outcomes
            for outcome in &step_def.outcomes {
                let should_follow = if let Some(condition) = &outcome.condition {
                    // Evaluate condition (simple string-based evaluation for now)
                    if let Some(outcome_value) = &result.outcome_value {
                        self.evaluate_condition(condition, outcome_value)
                    } else {
                        outcome.value.is_none()
                    }
                } else {
                    true
                };

                if should_follow {
                    next_steps.push(outcome.next_step);
                }
            }
        }

        Ok(next_steps)
    }

    /// Create execution pointers for next steps
    async fn create_execution_pointers(
        &self,
        instance: &WorkflowInstanceData,
        step_ids: Vec<i32>,
        parent_pointer_id: Option<Uuid>,
        branch_data: Option<&serde_json::Value>,
    ) -> WorkflowResult<Vec<ExecutionPointerData>> {
        let mut pointers = Vec::new();

        for step_id in step_ids {
            let pointer = ExecutionPointerData {
                id: Uuid::new_v4(),
                workflow_instance_id: instance.id,
                step_id,
                step_name: format!("Step_{}", step_id),
                active: true,
                status: ExecutionPointerStatus::Runnable,
                start_time: None,
                end_time: None,
                sleep_until: None,
                persistence_data: branch_data.cloned(),
                retry_count: 0,
                predecessor_id: parent_pointer_id,
                context_item: None,
                children: Vec::new(),
                event_name: None,
                event_key: None,
                event_published: false,
                event_data: None,
                outcome: None,
                scope: Vec::new(),
            };

            self.persistence.create_execution_pointer(&pointer).await?;
            pointers.push(pointer);
        }

        Ok(pointers)
    }

    /// Execute a single step
    async fn execute_single_step(
        &self,
        mut instance: WorkflowInstanceData,
        mut pointer: ExecutionPointerData,
        definition: Arc<WorkflowDefinition>,
    ) -> WorkflowResult<(Vec<ExecutionAction>, ExecutionPointerData)> {
        // Find the step definition
        let step_def = definition.steps
            .iter()
            .find(|s| s.id == pointer.step_id)
            .ok_or_else(|| WorkflowError::StepNotFound {
                step_id: pointer.step_id,
                workflow_id: definition.id.clone(),
            })?;

        // Create execution context
        let context = StepExecutionContext {
            workflow_data: instance.data.clone().unwrap_or(serde_json::Value::Null),
            step_data: pointer.context_item.clone(),
            persistence_data: pointer.persistence_data.clone(),
            correlation_id: instance.correlation_id.clone().unwrap_or_default(),
            workflow_instance_id: instance.id,
            step_id: pointer.step_id,
            step_name: step_def.name.clone(),
            attempt: pointer.retry_count + 1,
            cancellation_token: tokio_util::sync::CancellationToken::new(),
        };

        // Update pointer status
        pointer.status = ExecutionPointerStatus::Running;
        pointer.start_time = Some(Utc::now());
        self.persistence.update_execution_pointer(&pointer).await?;

        // Execute the step
        let execution_result = self.execute_step(&context, step_def.step_body.clone()).await;

        match execution_result {
            Ok(result) => {
                // Process successful execution
                let actions = self.process_execution_result(&mut instance, &mut pointer, result).await?;
                Ok((actions, pointer))
            }
            Err(error) => {
                // Handle step failure
                pointer.retry_count += 1;
                
                if self.should_retry_step(&pointer, &error).await? {
                    // Schedule retry
                    let retry_delay = self.calculate_retry_delay(&pointer, &error);
                    pointer.status = ExecutionPointerStatus::Sleeping;
                    pointer.sleep_until = Some(Utc::now() + chrono::Duration::from_std(retry_delay)?);
                    
                    self.persistence.update_execution_pointer(&pointer).await?;
                    
                    let action = ExecutionAction::ScheduleStep {
                        pointer_id: pointer.id,
                        step_id: pointer.step_id,
                        execute_time: pointer.sleep_until.unwrap(),
                    };
                    
                    Ok((vec![action], pointer))
                } else {
                    // Permanent failure
                    pointer.status = ExecutionPointerStatus::Failed;
                    pointer.end_time = Some(Utc::now());
                    
                    self.persistence.update_execution_pointer(&pointer).await?;
                    
                    // Fail the workflow if compensation is not enabled
                    if !self.config.enable_compensation {
                        self.fail_workflow(&mut instance, &error).await?;
                    }
                    
                    Err(error)
                }
            }
        }
    }

    fn evaluate_condition(
        &self,
        condition: &str,
        outcome_value: &serde_json::Value,
    ) -> bool {
        // Simple string-based evaluation for now
        // In a real implementation, this would be more robust
        if condition.is_empty() {
            return true; // No condition means always true
        }

        // Check if the outcome value matches the condition
        outcome_value.as_str() == Some(condition)
    }
}

#[async_trait]
impl WorkflowExecutor for EnhancedWorkflowExecutor {
    async fn execute_workflow(
        &self,
        instance: &mut WorkflowInstanceData,
    ) -> WorkflowResult<ExecutionSummary> {
        let start_time = std::time::Instant::now();
        let mut summary = ExecutionSummary {
            workflow_id: instance.id,
            steps_executed: 0,
            steps_failed: 0,
            steps_waiting: 0,
            workflow_completed: false,
            workflow_failed: false,
            actions: Vec::new(),
            next_execution: None,
            duration: std::time::Duration::default(),
            errors: Vec::new(),
        };

        tracing::info!(
            workflow_id = %instance.id,
            "Starting workflow execution"
        );

        // Validate the instance
        self.validate_instance(instance).await?;

        // Get workflow definition
        let definition = self.get_workflow_definition(
            &instance.workflow_definition_id,
            instance.version,
        ).await?;

        // Get runnable execution pointers
        let runnable_pointers = self.get_runnable_pointers(instance).await?;

        if runnable_pointers.is_empty() {
            // Check if workflow is complete
            if self.is_workflow_complete(instance) {
                self.complete_workflow(instance).await?;
                summary.workflow_completed = true;
            } else {
                // Calculate next execution time
                summary.next_execution = self.calculate_next_execution(instance).await?;
            }
        } else {
            // Execute runnable steps
            let max_concurrent = std::cmp::min(
                self.config.max_concurrency as usize,
                runnable_pointers.len(),
            );

            let mut tasks = Vec::new();
            for pointer in runnable_pointers.into_iter().take(max_concurrent) {
                let executor = self.clone(); // Assuming Clone implementation
                let definition_clone = definition.clone();
                let instance_clone = instance.clone();
                
                let task = tokio::spawn(async move {
                    executor.execute_single_step(instance_clone, pointer, definition_clone).await
                });
                tasks.push(task);
            }

            // Wait for all tasks to complete
            let results = futures::future::try_join_all(tasks).await
                .map_err(|e| WorkflowError::ExecutionError {
                    reason: format!("Task join error: {}", e),
                })?;

            // Process results
            for result in results {
                match result {
                    Ok((actions, _pointer)) => {
                        summary.steps_executed += 1;
                        summary.actions.extend(actions);
                    }
                    Err(error) => {
                        summary.steps_failed += 1;
                        summary.errors.push(error);
                    }
                }
            }

            // Update instance status if needed
            if summary.steps_failed > 0 && !self.config.enable_compensation {
                instance.status = WorkflowInstanceStatus::Terminated;
                summary.workflow_failed = true;
            } else if self.is_workflow_complete(instance) {
                self.complete_workflow(instance).await?;
                summary.workflow_completed = true;
            }
        }

        summary.duration = start_time.elapsed();
        Ok(summary)
    }

    async fn execute_step(
        &self,
        context: &StepExecutionContext,
        step_body: Arc<dyn StepBody>,
    ) -> WorkflowResult<ExecutionResult> {
        tracing::info!(
            step_name = %context.step_name,
            correlation_id = %context.correlation_id,
            "Executing step"
        );

        // Call setup if this is the first attempt
        if context.attempt == 1 {
            step_body.setup(context).await?;
        }

        // Execute the step with timeout
        let result = tokio::time::timeout(
            self.config.step_timeout,
            step_body.run(context)
        ).await;

        match result {
            Ok(step_result) => {
                match &step_result {
                    Ok(execution_result) => {
                        // Call cleanup if step completed successfully
                        if execution_result.proceed {
                            step_body.cleanup(context).await.ok(); // Don't fail if cleanup fails
                        }
                    }
                    Err(_) => {
                        // Step failed - cleanup is not called
                    }
                }
                step_result
            }
            Err(_) => {
                let error = WorkflowError::StepExecutionFailed {
                    step_name: context.step_name.clone(),
                    reason: "Step execution timeout".to_string(),
                };
                Err(error)
            }
        }
    }

    async fn process_execution_result(
        &self,
        instance: &mut WorkflowInstanceData,
        pointer: &mut ExecutionPointerData,
        result: ExecutionResult,
    ) -> WorkflowResult<Vec<ExecutionAction>> {
        let mut actions = Vec::new();

        match result {
            ExecutionResult { proceed: true, ref outcome_value, ref persistence_data, .. } => {
                // Step completed successfully
                pointer.status = ExecutionPointerStatus::Complete;
                pointer.end_time = Some(Utc::now());
                pointer.outcome = outcome_value.clone();
                
                if let Some(data) = persistence_data {
                    pointer.persistence_data = Some(data.clone());
                }

                // Get workflow definition and determine next steps
                let definition = self.get_workflow_definition(
                    &instance.workflow_definition_id,
                    instance.version,
                ).await?;

                // Create a temporary ExecutionResult for processing outcomes
                let temp_result = ExecutionResult { 
                    proceed: true, 
                    outcome_value: outcome_value.clone(), 
                    persistence_data: persistence_data.clone(), 
                    ..ExecutionResult::default() 
                };
                let next_step_ids = self.process_step_outcomes(&definition, pointer.step_id, &temp_result)?;
                
                if !next_step_ids.is_empty() {
                    let next_pointers = self.create_execution_pointers(
                        instance,
                        next_step_ids,
                        Some(pointer.id),
                        pointer.persistence_data.as_ref(),
                    ).await?;

                    for next_pointer in next_pointers {
                        actions.push(ExecutionAction::ScheduleStep {
                            pointer_id: next_pointer.id,
                            step_id: next_pointer.step_id,
                            execute_time: Utc::now(),
                        });
                    }
                }
            }
            
            ExecutionResult { proceed: false, sleep_for: Some(sleep_duration), persistence_data, .. } => {
                // Step is sleeping
                pointer.status = ExecutionPointerStatus::Sleeping;
                pointer.sleep_until = Some(Utc::now() + chrono::Duration::from_std(sleep_duration)?);
                
                if let Some(data) = persistence_data {
                    pointer.persistence_data = Some(data);
                }

                actions.push(ExecutionAction::ScheduleStep {
                    pointer_id: pointer.id,
                    step_id: pointer.step_id,
                    execute_time: Utc::now() + chrono::Duration::from_std(sleep_duration)?,
                });
            }

            ExecutionResult { proceed: false, branch_values, persistence_data, .. } if !branch_values.is_empty() => {
                // Create parallel branches
                pointer.status = ExecutionPointerStatus::WaitingForChildren;
                
                if let Some(data) = persistence_data {
                    pointer.persistence_data = Some(data);
                }

                // Create child execution pointers for each branch
                for (i, branch_data) in branch_values.iter().enumerate() {
                    let child_pointer = ExecutionPointerData {
                        id: Uuid::new_v4(),
                        workflow_instance_id: instance.id,
                        step_id: pointer.step_id + 1, // Next step in workflow
                        step_name: format!("{}_branch_{}", pointer.step_name, i),
                        active: true,
                        status: ExecutionPointerStatus::Runnable,
                        start_time: None,
                        end_time: None,
                        sleep_until: None,
                        persistence_data: Some(branch_data.clone()),
                        retry_count: 0,
                        predecessor_id: Some(pointer.id),
                        context_item: Some(branch_data.clone()),
                        children: Vec::new(),
                        event_name: None,
                        event_key: None,
                        event_published: false,
                        event_data: None,
                        outcome: None,
                        scope: Vec::new(),
                    };

                    self.persistence.create_execution_pointer(&child_pointer).await?;
                    pointer.children.push(child_pointer.id);

                    actions.push(ExecutionAction::ScheduleStep {
                        pointer_id: child_pointer.id,
                        step_id: child_pointer.step_id,
                        execute_time: Utc::now(),
                    });
                }
            }

            ExecutionResult { proceed: false, event_name: Some(event), event_key, event_as_of, persistence_data, .. } => {
                // Step is waiting for an event
                pointer.status = ExecutionPointerStatus::WaitingForEvent;
                pointer.event_name = Some(event.clone());
                pointer.event_key = event_key.clone();
                
                if let Some(data) = persistence_data {
                    pointer.persistence_data = Some(data);
                }

                // Create event subscription
                let subscription = crate::event::EventSubscription::new(
                    instance.id,
                    pointer.step_id,
                    event,
                    event_key,
);

                self.persistence.create_subscription(&subscription).await?;

                actions.push(ExecutionAction::CreateEventSubscription {
                    subscription_id: subscription.id,
                    event_name: subscription.event_name.clone(),
                    event_key: subscription.event_key.clone(),
                });
            }

            _ => {
                // Handle other execution results
                pointer.status = ExecutionPointerStatus::Complete;
                pointer.end_time = Some(Utc::now());
            }
        }

        // Update the execution pointer
        self.persistence.update_execution_pointer(pointer).await?;

        Ok(actions)
    }

    async fn calculate_next_execution(
        &self,
        instance: &WorkflowInstanceData,
    ) -> WorkflowResult<Option<DateTime<Utc>>> {
        let pointers = self.persistence.get_execution_pointers(instance.id).await?;
        
        let next_sleep_time = pointers
            .into_iter()
            .filter_map(|p| {
                if p.status == ExecutionPointerStatus::Sleeping {
                    p.sleep_until
                } else {
                    None
                }
            })
            .min();

        Ok(next_sleep_time)
    }

    fn is_workflow_complete(&self, instance: &WorkflowInstanceData) -> bool {
        // This would need access to execution pointers
        // For now, assume complete if status is set
        matches!(instance.status, WorkflowInstanceStatus::Complete)
    }

    async fn complete_workflow(&self, instance: &mut WorkflowInstanceData) -> WorkflowResult<()> {
        tracing::info!(
            workflow_id = %instance.id,
            "Completing workflow"
        );

        instance.status = WorkflowInstanceStatus::Complete;
        instance.complete_time = Some(Utc::now());
        
        self.persistence.update_workflow_instance(instance).await?;
        Ok(())
    }

    async fn fail_workflow(
        &self,
        instance: &mut WorkflowInstanceData,
        error: &WorkflowError,
    ) -> WorkflowResult<()> {
        tracing::error!(
            workflow_id = %instance.id,
            error = %error,
            "Failing workflow"
        );

        instance.status = WorkflowInstanceStatus::Terminated;
        instance.complete_time = Some(Utc::now());
        
        self.persistence.update_workflow_instance(instance).await?;
        Ok(())
    }

    async fn should_retry_step(
        &self,
        pointer: &ExecutionPointerData,
        error: &WorkflowError,
    ) -> WorkflowResult<bool> {
        if !error.should_retry() {
            return Ok(false);
        }

        let max_retries = 3; // TODO: Get from step definition or config
        Ok(pointer.retry_count < max_retries)
    }

    fn calculate_retry_delay(
        &self,
        pointer: &ExecutionPointerData,
        error: &WorkflowError,
    ) -> std::time::Duration {
        let base_delay = error.retry_delay();
        let multiplier = 2_u32.pow(pointer.retry_count as u32);
        let delay = base_delay * multiplier;

        // Cap at 5 minutes
        std::cmp::min(delay, std::time::Duration::from_secs(300))
    }

    async fn get_workflow_definition(
        &self,
        workflow_id: &str,
        version: i32,
    ) -> WorkflowResult<Arc<WorkflowDefinition>> {
        self.definitions.get_definition(workflow_id, version).await
    }

    async fn validate_instance(&self, instance: &WorkflowInstanceData) -> WorkflowResult<()> {
        if instance.workflow_definition_id.is_empty() {
            return Err(WorkflowError::InvalidWorkflowDefinition {
                reason: "Workflow definition ID is empty".to_string(),
            });
        }

        if instance.version <= 0 {
            return Err(WorkflowError::InvalidWorkflowDefinition {
                reason: "Workflow version must be positive".to_string(),
            });
        }

        // Verify the workflow definition exists
        self.definitions
            .get_definition(&instance.workflow_definition_id, instance.version)
            .await?;

        Ok(())
    }
}

// Implement Clone for EnhancedWorkflowExecutor if needed
impl Clone for EnhancedWorkflowExecutor {
    fn clone(&self) -> Self {
        Self {
            config: self.config.clone(),
            persistence: self.persistence.clone(),
            definitions: self.definitions.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::traits::persistence::WorkflowInstanceStatus;

    #[test]
    fn test_executor_config() {
        let config = ExecutorConfig::default();
        assert_eq!(config.max_concurrency, 10);
        assert!(config.enable_compensation);

        let custom_config = ExecutorConfig {
            max_concurrency: 20,
            step_timeout: std::time::Duration::from_secs(60),
            ..Default::default()
        };
        assert_eq!(custom_config.max_concurrency, 20);
        assert_eq!(
            custom_config.step_timeout,
            std::time::Duration::from_secs(60)
        );
    }

    #[test]
    fn test_executor_creation() {
        let executor = BasicWorkflowExecutor::new();
        assert_eq!(executor.config.max_concurrency, 10);

        let config = ExecutorConfig {
            max_concurrency: 5,
            ..Default::default()
        };
        let executor_with_config = BasicWorkflowExecutor::with_config(config);
        assert_eq!(executor_with_config.config.max_concurrency, 5);
    }

    #[tokio::test]
    async fn test_workflow_completion() {
        let executor = BasicWorkflowExecutor::new();
        let mut instance = WorkflowInstanceData {
            id: Uuid::new_v4(),
            workflow_definition_id: "test".to_string(),
            version: 1,
            description: None,
            reference: None,
            status: WorkflowInstanceStatus::Runnable,
            data: None,
            create_time: chrono::Utc::now(),
            complete_time: None,
            next_execution: None,
            node_id: None,
            correlation_id: None,
            tags: std::collections::HashMap::new(),
        };

        executor.complete_workflow(&mut instance).await.unwrap();
        assert_eq!(instance.status, WorkflowInstanceStatus::Complete);
        assert!(instance.complete_time.is_some());
    }

    #[tokio::test]
    async fn test_workflow_validation() {
        let executor = BasicWorkflowExecutor::new();

        let valid_instance = WorkflowInstanceData {
            id: Uuid::new_v4(),
            workflow_definition_id: "valid_workflow".to_string(),
            version: 1,
            description: None,
            reference: None,
            status: WorkflowInstanceStatus::Runnable,
            data: None,
            create_time: chrono::Utc::now(),
            complete_time: None,
            next_execution: None,
            node_id: None,
            correlation_id: None,
            tags: std::collections::HashMap::new(),
        };

        assert!(executor.validate_instance(&valid_instance).await.is_ok());

        let invalid_instance = WorkflowInstanceData {
            workflow_definition_id: "".to_string(), // Invalid: empty ID
            version: 0,                             // Invalid: non-positive version
            ..valid_instance
        };

        assert!(executor.validate_instance(&invalid_instance).await.is_err());
    }
}
