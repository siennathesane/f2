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
            Default,
            Debug,
            Clone,
            Eq,
            PartialEq,
            PartialOrd,
            Ord,
            serde::Serialize,
            serde::Deserialize,
            redis_macros::ToRedisArgs,
            redis_macros::FromRedisValue
        )]
        pub struct $name {
            $($field: $type,)*
            id: Uuid,
            name: String,
            description: Option<String>,
        }

        impl $name {
            /// Create a new builder for this node type
            pub fn builder() -> paste::paste!([<$name Builder>]) {
                paste::paste!([<$name Builder>]::new())
            }
        }
        
        paste::paste! {
            #[derive(Default, Debug)]
            pub struct [<$name Builder>] {
                $($field: Option<$type>,)*
                id: Option<Uuid>,
                name: Option<String>,
                description: Option<String>,
            }
            
            impl [<$name Builder>] {
                pub fn new() -> Self {
                    Self::default()
                }
                
                $(
                    /// Set the [<$field>] field
                    pub fn [<with_ $field>](mut self, value: $type) -> Self {
                        self.$field = Some(value);
                        self
                    }
                )*
                
                /// Set the name field
                pub fn with_name(mut self, value: String) -> Self {
                    self.name = Some(value);
                    self
                }

                /// Set the description field  
                pub fn with_description(mut self, value: String) -> Self {
                    self.description = Some(value);
                    self
                }
                
                /// Build the final node instance
                pub fn build(self) -> Result<$name, $crate::graph::Error> {
                    Ok($name {
                        $(
                            $field: self.$field.ok_or_else(|| $crate::graph::Error::MissingRequiredParameter(String::from(stringify!($field))))?,
                        )*
                        id: self.id.unwrap_or_else(Uuid::new_v4),
                        name: self.name.unwrap_or_default(),
                        description: self.description,
                    })
                }
                
                /// Build the final node instance, panicking on missing required fields
                pub fn build_unchecked(self) -> $name {
                    $name {
                        $(
                            $field: self.$field.expect(&format!("Field '{}' is required", stringify!($field))),
                        )*
                        id: self.id.unwrap_or_else(Uuid::new_v4),
                        name: self.name.unwrap_or_default(), // or .unwrap_or_else(String::new)
                        description: self.description,
                    }
                }
            }
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
            Default,
            Eq,
            PartialEq,
            PartialOrd,
            Ord,
            serde::Serialize,
            serde::Deserialize,
            redis_macros::ToRedisArgs,
            redis_macros::FromRedisValue
        )]
        pub struct $name {
            $($field: $type,)*
            id: Uuid,
            source: Uuid,
            target: Uuid,
        }

        impl $name {
            /// Create a new builder for this edge type
            pub fn builder() -> paste::paste!([<$name Builder>]) {
                paste::paste!([<$name Builder>]::new())
            }
        }
        
        // Generate the builder struct using paste
        paste::paste! {
            #[derive(Default, Debug)]
            pub struct [<$name Builder>] {
                $($field: Option<$type>,)*
                id: Option<Uuid>,
                source: Option<Uuid>,
                target: Option<Uuid>,
            }
        }
        
        // Generate the impl block separately to avoid paste/repetition conflicts
        paste::paste! {
            impl [<$name Builder>] {
                pub fn new() -> Self {
                    Self::default()
                }
                
                $(
                    /// Set the [<$field>] field
                    pub fn [<with_ $field>](mut self, value: $type) -> Self {
                        self.$field = Some(value);
                        self
                    }
                )*
                
                /// Set the id field
                pub fn with_id(mut self, value: Uuid) -> Self {
                    self.id = Some(value);
                    self
                }

                /// Set the source field
                pub fn with_source(mut self, value: Uuid) -> Self {
                    self.source = Some(value);
                    self
                }

                /// Set the target field
                pub fn with_target(mut self, value: Uuid) -> Self {
                    self.target = Some(value);
                    self
                }
                
                /// Build the final edge instance
                pub fn build(self) -> Result<$name, $crate::graph::Error> {
                    Ok($name {
                        $(
                            $field: self.$field.ok_or_else(|| $crate::graph::Error::MissingRequiredParameter(String::from(stringify!($field))))?,
                        )*
                        id: self.id.unwrap_or_else(Uuid::new_v4),
                        source: self.source.ok_or_else(|| $crate::graph::Error::MissingRequiredParameter(String::from("source")))?,
                        target: self.target.ok_or_else(|| $crate::graph::Error::MissingRequiredParameter(String::from("target")))?,
                    })
                }
                
                /// Build the final edge instance, panicking on missing required fields
                pub fn build_unchecked(self) -> $name {
                    $name {
                        $(
                            $field: self.$field.expect(&format!("Field '{}' is required", stringify!($field))),
                        )*
                        id: self.id.unwrap_or_else(Uuid::new_v4),
                        source: self.source.expect("Field 'source' is required"),
                        target: self.target.expect("Field 'target' is required"),
                    }
                }
            }
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
