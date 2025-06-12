# Generated from Kubernetes ServiceAccount: cnpg-cloudnative-pg
# Namespace: cnpg-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "cnpg_cloudnative_pg" {
  metadata {
    name      = "cnpg-cloudnative-pg"
    namespace = "cnpg-system"

    labels = {
      "app.kubernetes.io/instance"   = "cnpg"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudnative-pg"
      "app.kubernetes.io/version"    = "1.26.0"
      "helm.sh/chart"                = "cloudnative-pg-0.24.0"
    }
  }
}

