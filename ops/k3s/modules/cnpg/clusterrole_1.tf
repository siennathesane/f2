# Generated from Kubernetes ClusterRole: cnpg-cloudnative-pg-view
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cnpg_cloudnative_pg_view" {
  metadata {
    name = "cnpg-cloudnative-pg-view"

    labels = {
      "app.kubernetes.io/instance"   = "cnpg"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudnative-pg"
      "app.kubernetes.io/version"    = "1.26.0"
      "helm.sh/chart"                = "cloudnative-pg-0.24.0"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["backups", "clusters", "databases", "poolers", "publications", "scheduledbackups", "subscriptions"]
  }
}

