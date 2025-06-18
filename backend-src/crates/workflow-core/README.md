# Workflow Core - Rust

A lightweight, embeddable workflow engine for Rust applications with PostgreSQL persistence.

## Features

- **Type Safety**: Strongly typed workflow data and step interfaces
- **Async/Await**: Full async support with tokio integration  
- **Error Handling**: Comprehensive error types and retry mechanisms
- **PostgreSQL Persistence**: Production-ready database persistence with connection pooling
- **Events**: Event-driven workflow triggering and coordination
- **Transactions**: ACID transaction support for complex operations
- **Performance**: Optimized queries with proper indexing and connection pooling
- **Observability**: Built-in logging and tracing support

## Quick Start

Add to your `Cargo.toml`:

```toml
[dependencies]
workflow-core = "0.1.0"
tokio = { version = "1.0", features = ["full"] }
```

### Basic Usage

```rust
use workflow_core::prelude::*;
use workflow_core::persistence::PostgresPersistenceProvider;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize PostgreSQL persistence
    let persistence = PostgresPersistenceProvider::new(
        "postgresql://user:password@localhost/workflows"
    ).await?;
    
    // Run database migrations
    persistence.initialize().await?;
    
    // Create a workflow instance
    let workflow_data = WorkflowInstanceData {
        id: Uuid::new_v4(),
        workflow_definition_id: "my_workflow".to_string(),
        version: 1,
        description: Some("Example workflow".to_string()),
        reference: None,
        status: WorkflowInstanceStatus::Runnable,
        data: Some(serde_json::json!({"input": "hello"})),
        create_time: Utc::now(),
        complete_time: None,
        next_execution: None,
        node_id: None,
        correlation_id: None,
        tags: std::collections::HashMap::new(),
    };
    
    // Persist the workflow
    persistence.create_workflow_instance(&workflow_data).await?;
    
    // Get runnable workflows
    let runnable = persistence.get_runnable_instances(10).await?;
    println!("Found {} runnable workflows", runnable.len());
    
    Ok(())
}
```

### Event-Driven Workflows

```rust
use workflow_core::event::{Event, EventSubscription};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let persistence = PostgresPersistenceProvider::new("postgresql://...").await?;
    
    // Create an event
    let event = Event::new(
        "user_registered".to_string(),
        Some("user_123".to_string())
    ).with_event_data(serde_json::json!({
        "user_id": "123",
        "email": "user@example.com"
    }));
    
    // Store the event
    persistence.create_event(&event).await?;
    
    // Create a subscription
    let subscription = EventSubscription::new(
        Uuid::new_v4(), // workflow_id
        1,              // step_id
        "user_registered".to_string(),
        Some("user_123".to_string())
    );
    
    persistence.create_subscription(&subscription).await?;
    
    // Get matching subscriptions
    let subscriptions = persistence.get_subscriptions_for_event(
        "user_registered", 
        Some("user_123")
    ).await?;
    
    println!("Found {} matching subscriptions", subscriptions.len());
    Ok(())
}
```

### Transaction Support

```rust
use workflow_core::traits::persistence::TransactionalPersistenceProvider;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let persistence = PostgresPersistenceProvider::new("postgresql://...").await?;
    
    // Execute multiple operations atomically
    persistence.execute_transaction(|tx| Box::pin(async move {
        // Create workflow instance
        tx.create_workflow_instance(&workflow_data).await?;
        
        // Create execution pointers
        tx.create_execution_pointers(workflow_data.id, &pointers).await?;
        
        // Create execution history entry
        tx.create_execution_history(&history_entry).await?;
        
        Ok(())
    })).await?;
    
    Ok(())
}
```

## Database Setup

The PostgreSQL persistence provider requires a PostgreSQL database with the workflow schema. The migrations are included and will run automatically when you call `initialize()`.

### Manual Migration

If you prefer to run migrations manually:

```sql
-- See migrations/001_initial_schema.sql for the complete schema
```

### Environment Configuration

```bash
export DATABASE_URL="postgresql://user:password@localhost:5432/workflows"
```

## Performance Considerations

The PostgreSQL provider includes several performance optimizations:

- **Connection Pooling**: Efficient connection reuse
- **Proper Indexing**: Optimized queries for common operations  
- **Batched Operations**: Support for bulk inserts and updates
- **Query Optimization**: Prepared statements and efficient joins
- **JSONB Support**: Efficient storage and querying of workflow data

### Monitoring

```rust
// Get performance statistics
let stats = persistence.get_workflow_stats().await?;
println!("Total workflows: {}", stats.total_workflows);
println!("Running workflows: {}", stats.running_workflows);

// Get storage information
let storage = persistence.get_storage_stats().await?;
println!("Database size: {} bytes", storage.total_size_bytes);

// PostgreSQL-specific performance analysis
let analysis = persistence.analyze_performance().await?;
for query in analysis.slow_queries {
    println!("Slow query: {} ({}ms avg)", query.query, query.avg_duration_ms);
}
```

## Error Handling

The library provides comprehensive error handling with automatic retry classification:

```rust
use workflow_core::models::error::{WorkflowError, ErrorClass};

match workflow_operation().await {
    Err(WorkflowError::PersistenceError(sqlx::Error::PoolTimedOut)) => {
        // This is classified as Transient and will be retried
        println!("Database connection timeout - will retry");
    }
    Err(e) if e.should_retry() => {
        // Automatic retry logic
        tokio::time::sleep(e.retry_delay()).await;
    }
    Err(e) => {
        // Permanent error - handle appropriately
        eprintln!("Workflow error: {}", e);
    }
    Ok(result) => {
        // Success
    }
}
```

## Architecture

The workflow engine uses a clean architecture with the following layers:

- **Traits**: Core interfaces for extensibility
- **Models**: Data structures and error types
- **Execution**: Workflow execution engine
- **Persistence**: Database abstraction layer
- **Builder**: Fluent API for workflow construction

This design allows for easy testing, mocking, and extension with custom persistence providers.

## Contributing

This crate follows standard Rust conventions and uses:

- `rustfmt` for code formatting
- `clippy` for linting
- `cargo test` for testing
- Documentation tests for examples

## License

[Add your license information here]

## Changelog

### 0.1.0

- Initial release
- PostgreSQL persistence provider
- Basic workflow execution engine
- Event system
- Transaction support
- Performance optimizations
