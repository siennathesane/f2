# Generated from Kubernetes ServiceAccount: longhorn-support-bundle
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "longhorn_support_bundle" {
  metadata {
    name      = "longhorn-support-bundle"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }
}

