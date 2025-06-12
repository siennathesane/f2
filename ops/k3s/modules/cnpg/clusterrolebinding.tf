# Generated from Kubernetes ClusterRoleBinding: cnpg-cloudnative-pg
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role_binding" "cnpg_cloudnative_pg" {
  metadata {
    name = "cnpg-cloudnative-pg"

    labels = {
      "app.kubernetes.io/instance"   = "cnpg"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudnative-pg"
      "app.kubernetes.io/version"    = "1.26.0"
      "helm.sh/chart"                = "cloudnative-pg-0.24.0"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cnpg-cloudnative-pg"
    namespace = "cnpg-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cnpg-cloudnative-pg"
  }
}

