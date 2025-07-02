use crate::define_node;
use crate::graph::types::{Node, ParameterType, Parameters};
use crate::graph::Error;
use async_trait::async_trait;
use std::collections::BTreeMap;
use uuid::Uuid;

define_node!(ParamsNode {
    params: Parameters,
});

#[async_trait]
impl Node for ParamsNode {
    fn id(&self) -> Uuid {
        self.id
    }

    fn name(&self) -> String {
        self.name.clone()
    }

    fn description(&self) -> Option<String> {
        self.description.clone()
    }

    fn is_ok(&self) -> bool {
        todo!()
    }

    async fn execute(
        &self,
        context: BTreeMap<String, ParameterType>,
    ) -> Result<BTreeMap<String, ParameterType>, Error> {
        todo!()
    }
}
