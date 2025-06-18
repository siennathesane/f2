-- Initial workflow-core database schema
-- Based on the original C# Entity Framework implementation

-- Create schema for workflow tables
CREATE SCHEMA IF NOT EXISTS wfc;

-- Workflows table - stores workflow instances
CREATE TABLE wfc.workflows (
    persistence_id BIGSERIAL PRIMARY KEY,
    instance_id UUID NOT NULL UNIQUE,
    workflow_definition_id VARCHAR(200) NOT NULL,
    version INTEGER NOT NULL,
    description VARCHAR(500),
    reference VARCHAR(200),
    status INTEGER NOT NULL DEFAULT 0, -- 0=Runnable, 1=Suspended, 2=Complete, 3=Terminated
    data JSONB,
    create_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    complete_time TIMESTAMPTZ,
    next_execution BIGINT,
    node_id VARCHAR(100), -- For distributed execution
    correlation_id VARCHAR(200),
    tags JSONB DEFAULT '{}'::jsonb
);

-- Execution pointers table - tracks step execution state
CREATE TABLE wfc.execution_pointers (
    persistence_id BIGSERIAL PRIMARY KEY,
    workflow_id BIGINT NOT NULL REFERENCES wfc.workflows(persistence_id) ON DELETE CASCADE,
    id UUID NOT NULL,
    step_id INTEGER NOT NULL,
    step_name VARCHAR(200),
    active BOOLEAN NOT NULL DEFAULT true,
    sleep_until TIMESTAMPTZ,
    persistence_data JSONB,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    event_name VARCHAR(100),
    event_key VARCHAR(100),
    event_published BOOLEAN NOT NULL DEFAULT false,
    event_data JSONB,
    retry_count INTEGER NOT NULL DEFAULT 0,
    children JSONB DEFAULT '[]'::jsonb, -- Array of child pointer UUIDs
    context_item JSONB,
    predecessor_id UUID,
    outcome JSONB,
    status INTEGER NOT NULL DEFAULT 1, -- 1=Pending, 2=Running, 3=Complete, 4=Sleeping, 5=WaitingForEvent, 6=Failed, 7=Compensated, 8=Cancelled, 9=PendingPredecessor
    scope JSONB DEFAULT '[]'::jsonb -- Array of scope strings
);

-- Execution errors table - tracks workflow execution errors
CREATE TABLE wfc.execution_errors (
    persistence_id BIGSERIAL PRIMARY KEY,
    workflow_instance_id UUID NOT NULL,
    execution_pointer_id UUID,
    step_id INTEGER,
    step_name VARCHAR(200),
    error_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    error_type VARCHAR(200) NOT NULL,
    error_message TEXT NOT NULL,
    error_details JSONB,
    retry_count INTEGER NOT NULL DEFAULT 0,
    correlation_id VARCHAR(200),
    resolved BOOLEAN NOT NULL DEFAULT false
);

-- Extension attributes table - key-value attributes for execution pointers
CREATE TABLE wfc.extension_attributes (
    persistence_id BIGSERIAL PRIMARY KEY,
    execution_pointer_id BIGINT NOT NULL REFERENCES wfc.execution_pointers(persistence_id) ON DELETE CASCADE,
    attribute_key VARCHAR(100) NOT NULL,
    attribute_value TEXT
);

-- Event subscriptions table - tracks workflow event subscriptions
CREATE TABLE wfc.subscriptions (
    persistence_id BIGSERIAL PRIMARY KEY,
    subscription_id UUID NOT NULL UNIQUE,
    workflow_id UUID NOT NULL,
    step_id INTEGER NOT NULL,
    event_name VARCHAR(200) NOT NULL,
    event_key VARCHAR(200),
    subscribe_as_of TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    subscription_data JSONB,
    external_token VARCHAR(200),
    external_worker_id VARCHAR(200),
    external_token_expiry TIMESTAMPTZ
);

-- Events table - stores published events
CREATE TABLE wfc.events (
    persistence_id BIGSERIAL PRIMARY KEY,
    event_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    event_name VARCHAR(200) NOT NULL,
    event_key VARCHAR(200),
    event_data JSONB,
    event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_processed BOOLEAN NOT NULL DEFAULT false,
    workflow_id UUID
);

-- Execution history table - audit trail of workflow execution
CREATE TABLE wfc.execution_history (
    persistence_id BIGSERIAL PRIMARY KEY,
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    workflow_instance_id UUID NOT NULL,
    step_id INTEGER,
    step_name VARCHAR(200),
    execution_pointer_id UUID,
    event_type INTEGER NOT NULL, -- 1=StepStarted, 2=StepCompleted, etc.
    event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    details JSONB,
    correlation_id VARCHAR(200),
    duration_ms BIGINT
);

-- Scheduled commands table - for delayed/scheduled operations
CREATE TABLE wfc.scheduled_commands (
    persistence_id BIGSERIAL PRIMARY KEY,
    command_name VARCHAR(200) NOT NULL,
    data JSONB NOT NULL,
    execute_time TIMESTAMPTZ NOT NULL,
    subscription_id UUID,
    command_id UUID NOT NULL DEFAULT gen_random_uuid()
);

-- Performance indexes
CREATE INDEX CONCURRENTLY idx_workflows_status ON wfc.workflows(status);
CREATE INDEX CONCURRENTLY idx_workflows_next_execution ON wfc.workflows(next_execution) WHERE next_execution IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_workflows_definition_id ON wfc.workflows(workflow_definition_id);
CREATE INDEX CONCURRENTLY idx_workflows_correlation_id ON wfc.workflows(correlation_id) WHERE correlation_id IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_workflows_create_time ON wfc.workflows(create_time);
CREATE INDEX CONCURRENTLY idx_workflows_node_id ON wfc.workflows(node_id) WHERE node_id IS NOT NULL;

CREATE INDEX CONCURRENTLY idx_execution_pointers_workflow_id ON wfc.execution_pointers(workflow_id);
CREATE INDEX CONCURRENTLY idx_execution_pointers_active ON wfc.execution_pointers(active) WHERE active = true;
CREATE INDEX CONCURRENTLY idx_execution_pointers_sleep_until ON wfc.execution_pointers(sleep_until) WHERE sleep_until IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_execution_pointers_event ON wfc.execution_pointers(event_name, event_key) WHERE event_name IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_execution_pointers_status ON wfc.execution_pointers(status);
CREATE INDEX CONCURRENTLY idx_execution_pointers_predecessor ON wfc.execution_pointers(predecessor_id) WHERE predecessor_id IS NOT NULL;

CREATE INDEX CONCURRENTLY idx_execution_errors_workflow ON wfc.execution_errors(workflow_instance_id);
CREATE INDEX CONCURRENTLY idx_execution_errors_time ON wfc.execution_errors(error_time);
CREATE INDEX CONCURRENTLY idx_execution_errors_resolved ON wfc.execution_errors(resolved) WHERE resolved = false;

CREATE INDEX CONCURRENTLY idx_extension_attributes_pointer ON wfc.extension_attributes(execution_pointer_id);
CREATE INDEX CONCURRENTLY idx_extension_attributes_key ON wfc.extension_attributes(attribute_key);

CREATE INDEX CONCURRENTLY idx_subscriptions_event ON wfc.subscriptions(event_name, event_key);
CREATE INDEX CONCURRENTLY idx_subscriptions_workflow ON wfc.subscriptions(workflow_id);
CREATE INDEX CONCURRENTLY idx_subscriptions_token_expiry ON wfc.subscriptions(external_token_expiry) WHERE external_token_expiry IS NOT NULL;

CREATE INDEX CONCURRENTLY idx_events_name_key ON wfc.events(event_name, event_key);
CREATE INDEX CONCURRENTLY idx_events_processed ON wfc.events(is_processed) WHERE is_processed = false;
CREATE INDEX CONCURRENTLY idx_events_time ON wfc.events(event_time);

CREATE INDEX CONCURRENTLY idx_execution_history_workflow ON wfc.execution_history(workflow_instance_id);
CREATE INDEX CONCURRENTLY idx_execution_history_time ON wfc.execution_history(event_time);
CREATE INDEX CONCURRENTLY idx_execution_history_event_type ON wfc.execution_history(event_type);

CREATE INDEX CONCURRENTLY idx_scheduled_commands_execute_time ON wfc.scheduled_commands(execute_time);
CREATE INDEX CONCURRENTLY idx_scheduled_commands_subscription ON wfc.scheduled_commands(subscription_id) WHERE subscription_id IS NOT NULL;

-- Additional performance optimization: partial indexes for common queries
CREATE INDEX CONCURRENTLY idx_workflows_runnable ON wfc.workflows(next_execution, persistence_id) 
    WHERE status = 0 AND (next_execution IS NULL OR next_execution <= EXTRACT(EPOCH FROM NOW()) * 1000);

CREATE INDEX CONCURRENTLY idx_pointers_waiting_for_event ON wfc.execution_pointers(event_name, event_key, workflow_id) 
    WHERE status = 5 AND active = true;

-- Add helpful database functions
CREATE OR REPLACE FUNCTION wfc.get_workflow_stats()
RETURNS TABLE(
    total_workflows BIGINT,
    running_workflows BIGINT,
    completed_workflows BIGINT,
    failed_workflows BIGINT,
    suspended_workflows BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_workflows,
        COUNT(*) FILTER (WHERE status = 0) as running_workflows,
        COUNT(*) FILTER (WHERE status = 2) as completed_workflows,
        COUNT(*) FILTER (WHERE status = 3) as failed_workflows,
        COUNT(*) FILTER (WHERE status = 1) as suspended_workflows
    FROM wfc.workflows;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old completed workflows
CREATE OR REPLACE FUNCTION wfc.purge_old_workflows(older_than TIMESTAMPTZ)
RETURNS BIGINT AS $$
DECLARE
    deleted_count BIGINT;
BEGIN
    -- Delete execution history first (may be referenced)
    DELETE FROM wfc.execution_history 
    WHERE workflow_instance_id IN (
        SELECT instance_id FROM wfc.workflows 
        WHERE complete_time < older_than AND status IN (2, 3)
    );
    
    -- Delete execution errors
    DELETE FROM wfc.execution_errors 
    WHERE workflow_instance_id IN (
        SELECT instance_id FROM wfc.workflows 
        WHERE complete_time < older_than AND status IN (2, 3)
    );
    
    -- Delete workflows (cascades to execution_pointers and extension_attributes)
    DELETE FROM wfc.workflows 
    WHERE complete_time < older_than AND status IN (2, 3);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Comment on schema for documentation
COMMENT ON SCHEMA wfc IS 'Workflow Core persistence schema for workflow engine data storage';
COMMENT ON TABLE wfc.workflows IS 'Primary workflow instances with execution metadata';
COMMENT ON TABLE wfc.execution_pointers IS 'Individual step execution state tracking';
COMMENT ON TABLE wfc.execution_errors IS 'Error logging and tracking for debugging';
COMMENT ON TABLE wfc.extension_attributes IS 'Flexible key-value attributes for execution pointers';
COMMENT ON TABLE wfc.subscriptions IS 'Event subscription tracking for workflow coordination';
COMMENT ON TABLE wfc.events IS 'Published events for workflow triggering and communication';
COMMENT ON TABLE wfc.execution_history IS 'Audit trail of workflow execution for monitoring';
COMMENT ON TABLE wfc.scheduled_commands IS 'Delayed command execution scheduling';
