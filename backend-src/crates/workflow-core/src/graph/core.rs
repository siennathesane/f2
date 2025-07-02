use crate::graph::types::{Edge, Node};
use crate::graph::Error;
use crate::graph::Error::{EdgeAlreadyExists, NodeNotFound};
use std::collections::BTreeMap;
use serde::{Deserialize, Serialize};
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
    pub fn new() -> Self {
        Core {
            nodes: BTreeMap::new(),
            outgoing_edges: BTreeMap::new(),
            incoming_edges: BTreeMap::new(),
            edges: BTreeMap::new(),
        }
    }

    pub fn add_node(&mut self, node: N) -> Result<(), Error> {
        self.nodes.insert(node.id(), node);
        Ok(())
    }

    pub fn get_node(&self, id: &Uuid) -> Option<&N> {
        self.nodes.get(id)
    }

    pub fn add_edge(&mut self, src: N, dst: N, edge: Option<E>) -> Result<(), Error> {
        if !self.nodes.contains_key(&src.id()) {
            return Err(NodeNotFound(src.name()));
        }

        if !self.nodes.contains_key(&dst.id()) {
            return Err(NodeNotFound(dst.name()));
        }

        if let Some(existing_edge) = self
            .edges
            .values()
            .find(|e| e.source() == src.id() && e.target() == dst.id())
        {
            return Err(EdgeAlreadyExists(existing_edge.id().to_string()));
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
            .push(edge.source());

        Ok(())
    }

    pub fn get_edge(&self, id: &Uuid) -> Option<&E> {
        self.edges.get(id)
    }
    
    pub fn get_edges_from(&self, id: &Uuid) -> Vec<&E> {
        self.outgoing_edges
            .get(id)
            .map_or(Vec::new(), |edges| {
                edges
                    .iter()
                    .filter_map(|edge_id| self.edges.get(edge_id))
                    .collect()
            })
    }
    
    pub fn get_edges_to(&self, id: &Uuid) -> Vec<&E> {
        self.incoming_edges
            .get(id)
            .map_or(Vec::new(), |edges| {
                edges
                    .iter()
                    .filter_map(|edge_id| self.edges.get(edge_id))
                    .collect()
            })
    }

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
    
    pub fn remove_edge(&mut self, id: &Uuid) -> Result<E, Error> {
        if let Some(edge) = self.edges.remove(id) {
            if let Some(edges) = self.outgoing_edges.get_mut(&edge.source()) {
                edges.retain(|&e| e != *id);
            }
            if let Some(edges) = self.incoming_edges.get_mut(&edge.target()) {
                edges.retain(|&e| e != edge.source());
            }
            Ok(edge)
        } else {
            Err(Error::EdgeNotFound(id.to_string()))
        }
    }
}
