use crate::graph::types::{Edge, Node};
use crate::graph::Error;
use crate::graph::Error::{EdgeAlreadyExists, NodeNotFound};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use uuid::Uuid;

#[derive(Debug, Default, Clone, Serialize, Deserialize)]
pub struct Core<N, E>
where
    N: Node,
    E: Edge,
{
    nodes: BTreeMap<Uuid, N>,
    outgoing_edges: BTreeMap<Uuid, Vec<Uuid>>,
    incoming_edges: BTreeMap<Uuid, Vec<Uuid>>,
    edges: BTreeMap<Uuid, E>,
}

impl<N: Node, E: Edge> Core<N, E> {
    /// Creates a new empty graph.
    pub fn new() -> Self {
        Core {
            nodes: BTreeMap::new(),
            outgoing_edges: BTreeMap::new(),
            incoming_edges: BTreeMap::new(),
            edges: BTreeMap::new(),
        }
    }

    /// Add a node to the graph.
    pub fn add_node(&mut self, node: N) -> Result<(), Error> {
        self.nodes.insert(node.id(), node);
        Ok(())
    }

    /// Get a reference to a node by its ID.
    pub fn get_node(&self, id: &Uuid) -> Option<&N> {
        self.nodes.get(id)
    }
    
    /// Get all nodes in the graph.
    pub fn get_nodes(&self) -> Vec<&N> {
        self.nodes.values().collect()
    }

    /// Add an edge between two nodes.
    pub fn add_edge(&mut self, src: N, dst: N, edge: Option<E>) -> Result<(), Error> {
        if !self.nodes.contains_key(&src.id()) {
            return Err(NodeNotFound(src.name()));
        }

        if !self.nodes.contains_key(&dst.id()) {
            return Err(NodeNotFound(dst.name()));
        }

        if self.edges.values().any(|e| e.source() == src.id() && e.target() == dst.id())
        {
            return Err(EdgeAlreadyExists(format!(
                "Edge from {} to {} already exists",
                src.name(),
                dst.name()
            )));
        }

        let edge = edge.unwrap_or_default();

        let id = edge.id();
        self.edges.insert(edge.id(), edge);

        let edge = match self.edges.get(&id) {
            Some(edge) => edge,
            None => panic!("Cannot fetch edge added to the graph"),
        };

        self.outgoing_edges
            .entry(edge.source())
            .or_default()
            .push(edge.id());

        self.incoming_edges
            .entry(edge.target())
            .or_default()
            .push(edge.id());

        Ok(())
    }

    /// Get a reference to an edge by its ID.
    pub fn get_edge(&self, id: &Uuid) -> Option<&E> {
        self.edges.get(id)
    }

    /// Get all outgoing edges from a node.
    pub fn get_edges_from(&self, id: &Uuid) -> Vec<&E> {
        self.outgoing_edges.get(id).map_or(Vec::new(), |edges| {
            edges
                .iter()
                .filter_map(|edge_id| self.edges.get(edge_id))
                .collect()
        })
    }

    /// Get all incoming edges to a node.
    pub fn get_edges_to(&self, id: &Uuid) -> Vec<&E> {
        self.incoming_edges.get(id).map_or(Vec::new(), |edges| {
            edges
                .iter()
                .filter_map(|edge_id| self.edges.get(edge_id))
                .collect()
        })
    }

    /// Remove a node and it's associated edges from the graph.
    pub fn remove_node(&mut self, id: &Uuid) -> Result<N, Error> {
        if let Some(node) = self.nodes.remove(id) {
            if let Some(edges) = self.outgoing_edges.remove(id) {
                for edge_id in edges {
                    self.edges.remove(&edge_id);
                }
            }
            if let Some(edges) = self.incoming_edges.remove(id) {
                for edge_id in edges {
                    self.edges.remove(&edge_id);
                }
            }
            Ok(node)
        } else {
            Err(NodeNotFound(id.to_string()))
        }
    }

    /// Remove an edge from the graph.
    pub fn remove_edge(&mut self, id: &Uuid) -> Result<E, Error> {
        if let Some(edge) = self.edges.remove(id) {
            if let Some(edges) = self.outgoing_edges.get_mut(&edge.source()) {
                edges.retain(|&e| e != *id);
            }
            if let Some(edges) = self.incoming_edges.get_mut(&edge.target()) {
                edges.retain(|&e| e != *id);
            }
            Ok(edge)
        } else {
            Err(Error::EdgeNotFound(id.to_string()))
        }
    }
}

#[cfg(test)]
mod tests {
    use async_trait::async_trait;
    use petgraph::visit::NodeRef;
    use crate::{define_edge, define_node};
    use crate::graph::types::{Condition, Parameters};
    use super::*;

    // Mock implementations for testing
    define_node!(TestNode {});

    #[async_trait]
    impl Node for TestNode {
        fn id(&self) -> Uuid {
            self.id
        }

        fn name(&self) -> String {
            self.name.clone()
        }

        fn description(&self) -> Option<String> {
            unimplemented!()
        }

        fn is_ok(&self) -> bool {
            unimplemented!()
        }

        async fn execute(&self, context: Parameters) -> Result<Parameters, Error> {
            unimplemented!()
        }
    }
    
    define_edge!(TestEdge {});

    impl Edge for TestEdge {
        fn id(&self) -> Uuid {
            self.id
        }

        fn source(&self) -> Uuid {
            self.source
        }

        fn target(&self) -> Uuid {
            self.target
        }

        fn condition(&self) -> Condition {
            unimplemented!()
        }
    }
    
    #[test]
    fn test_new_graph() {
        let graph: Core<TestNode, TestEdge> = Core::new();
        assert!(graph.get_nodes().is_empty());
    }

    // Test node operations
    #[test]
    fn test_node_operations() {
        let mut graph = Core::<TestNode, TestEdge>::new();
        let node = TestNode::builder().with_name(String::from("test-node")).with_description(String::from("A test node")).build().unwrap();

        let node_id = node.id();
        assert!(graph.add_node(node.clone()).is_ok());

        // Test get_node
        let retrieved_node = graph.get_node(&node_id);
        assert!(retrieved_node.is_some());
        assert_eq!(retrieved_node.unwrap().name(), "test-node");

        // Test get_nodes
        let all_nodes = graph.get_nodes();
        assert_eq!(all_nodes.len(), 1);
        assert_eq!(*all_nodes[0], node);

        // Test remove_node
        let removed = graph.remove_node(&node_id).unwrap();
        assert_eq!(removed.name(), "test-node");
        assert!(graph.get_node(&node_id).is_none());
    }
    
    #[test]
    fn test_edge_operations() {
        let mut graph = Core::<TestNode, TestEdge>::new();

        let node1 = TestNode::builder().with_name("Node 1".to_string())
            .with_description("First test node".to_string())
            .build()
            .unwrap();

        let node2 = TestNode::builder().with_name("Node 2".to_string())
            .with_description("Second test node".to_string())
            .build()
            .unwrap();

        let node1_id = node1.id();
        let node2_id = node2.id();

        graph.add_node(node1.clone()).unwrap();
        graph.add_node(node2.clone()).unwrap();

        // Create edge with custom properties
        let edge = TestEdge::builder()
            .with_source(node1_id)
            .with_target(node2_id)
            .build()
            .unwrap();
        let edge_id = edge.id();

        // Add and verify edge
        assert!(graph.add_edge(node1.clone(), node2.clone(), Some(edge)).is_ok());

        // Test get_edge
        let retrieved_edge = graph.get_edge(&edge_id);
        assert!(retrieved_edge.is_some());

        // Test get_edges_from
        let edges_from = graph.get_edges_from(&node1_id);
        assert_eq!(edges_from.len(), 1);
        assert_eq!(edges_from[0].source(), node1_id);
        assert_eq!(edges_from[0].target(), node2_id);

        // Test get_edges_to
        let edges_to = graph.get_edges_to(&node2_id);
        assert_eq!(edges_to.len(), 1);

        // Test remove_edge
        let removed_edge = graph.remove_edge(&edge_id).unwrap();
        assert_eq!(removed_edge.source(), node1_id);
        assert_eq!(removed_edge.target(), node2_id);
        assert!(graph.get_edge(&edge_id).is_none());
    }
}
