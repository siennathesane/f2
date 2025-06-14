# Generated from Kubernetes ServiceAccount: longhorn-service-account
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "longhorn_service_account" {
  metadata {
    name      = "longhorn-service-account"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }
}

