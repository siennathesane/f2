# Generated from Kubernetes ClusterRoleBinding: minio-operator-binding
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role_binding" "minio_operator_binding" {
  metadata {
    name = "minio-operator-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "minio-operator"
    namespace = "minio-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "minio-operator-role"
  }
}
