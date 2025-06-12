# Generated from Kubernetes ServiceAccount: contour
# Namespace: contour
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "contour" {
  metadata {
    name      = "contour"
    namespace = "contour"
  }
}

