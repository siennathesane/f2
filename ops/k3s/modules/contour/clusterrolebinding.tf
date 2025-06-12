# Generated from Kubernetes ClusterRoleBinding: contour
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role_binding" "contour" {
  metadata {
    name = "contour"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "contour"
    namespace = "contour"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "contour"
  }
}

