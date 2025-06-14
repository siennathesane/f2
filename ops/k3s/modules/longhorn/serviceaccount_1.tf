# Generated from Kubernetes ServiceAccount: longhorn-ui-service-account
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "longhorn_ui_service_account" {
  metadata {
    name      = "longhorn-ui-service-account"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }
}

