# Generated from Kubernetes ServiceAccount: envoy
# Namespace: contour
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "envoy" {
  metadata {
    name      = "envoy"
    namespace = "contour"
  }
}

