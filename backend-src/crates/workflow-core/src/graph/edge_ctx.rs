use crate::graph::types::{Condition, Edge, EdgeContext, ParameterType};
use petgraph::graph::EdgeIndex;
use redis_macros::{FromRedisValue, ToRedisArgs};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fmt::Debug;
use uuid::Uuid;

#[derive(Default, Clone, Serialize, Deserialize, FromRedisValue, ToRedisArgs)]
pub struct EdgeCtx {
    pub id: Uuid,
    pub params: BTreeMap<String, ParameterType>,
    /// The index of the owning edge in the graph
    pub idx: u32,
}

impl EdgeContext for EdgeCtx {
    fn set(&mut self, key: String, value: ParameterType) {
        self.params.insert(key, value);
    }

    fn get(&self, key: &str) -> Option<&ParameterType> {
        self.params.get(key)
    }

    fn params(&self) -> BTreeMap<String, ParameterType> {
        self.params.clone()
    }
}

impl Debug for EdgeCtx {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("EdgeCtx")
            .field("id", &self.id)
            .field("params", &self.params)
            .finish()
    }
}
