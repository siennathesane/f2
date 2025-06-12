# Generated from Kubernetes ConfigMap: cnpg-controller-manager-config
# Namespace: cnpg-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_config_map" "cnpg_controller_manager_config" {
  metadata {
    name      = "cnpg-controller-manager-config"
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

