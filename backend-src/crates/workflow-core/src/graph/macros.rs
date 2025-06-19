/// Macro to define a node type with all required traits enforced at compile time.
///
/// Usage:
/// ```
/// define_node!(MyNode {
///     id: Uuid,
///     name: String,
///     description: Option<String>,
/// });
///
/// impl Node for MyNode {
///     fn id(&self) -> Uuid { self.id }
///     fn name(&self) -> &str { &self.name }
///     // ... rest of implementation
/// }
/// ```
#[macro_export]
macro_rules! define_node {
    ($name:ident { $($field:ident: $type:ty),* $(,)? }) => {
        #[derive(
            Clone,
            Debug,
            serde::Serialize,
            serde::Deserialize,
            redis_macros::ToRedisArgs,
            redis_macros::FromRedisValue
        )]
        pub struct $name {
            $($field: $type,)*
        }

        // Compile-time assertion to ensure all required traits are implemented
        const _: fn() = || {
            fn assert_node_traits<'a, T>()
            where
                T: $crate::graph::types::Node
                    + serde::Serialize
                    + serde::de::DeserializeOwned
                    + redis::ToRedisArgs
                    + redis::FromRedisValue
                    + Send
                    + Sync
                    + 'static
            {}
            assert_node_traits::<$name>();
        };
    };
}

/// Macro to define an edge type with all required traits enforced at compile time.
///
/// Usage:
/// ```
/// define_edge!(MyEdge {
///     id: Uuid,
///     source: Uuid,
///     target: Uuid,
///     name: String,
/// });
///
/// impl Edge for MyEdge {
///     fn id(&self) -> Uuid { self.id }
///     fn source(&self) -> Uuid { self.source }
///     // ... rest of implementation
/// }
/// ```
#[macro_export]
macro_rules! define_edge {
    ($name:ident { $($field:ident: $type:ty),* $(,)? }) => {
        #[derive(
            Clone,
            Debug,
            serde::Serialize,
            serde::Deserialize,
            redis_macros::ToRedisArgs,
            redis_macros::FromRedisValue
        )]
        pub struct $name {
            $($field: $type,)*
        }

        // Compile-time assertion to ensure all required traits are implemented
        const _: fn() = || {
            fn assert_edge_traits<T>()
            where
                T: $crate::graph::types::Edge
                    + serde::Serialize
                    + serde::de::DeserializeOwned
                    + redis::ToRedisArgs
                    + redis::FromRedisValue
                    + Send
                    + Sync
                    + 'static
            {}
            assert_edge_traits::<$name>();
        };
    };
}

/// Convenience macro for defining both node and edge types in one go
#[macro_export]
macro_rules! define_graph_types {
    (
        node $node_name:ident { $($node_field:ident: $node_type:ty),* $(,)? }
        edge $edge_name:ident { $($edge_field:ident: $edge_type:ty),* $(,)? }
    ) => {
        define_node!($node_name { $($node_field: $node_type),* });
        define_edge!($edge_name { $($edge_field: $edge_type),* });
    };
}
