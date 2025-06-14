# Generated from Kubernetes ClusterRoleBinding: longhorn-support-bundle
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role_binding" "longhorn_support_bundle" {
  metadata {
    name = "longhorn-support-bundle"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "longhorn-support-bundle"
    namespace = "longhorn-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}

