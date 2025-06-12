# Generated from Kubernetes ServiceAccount: contour-certgen
# Namespace: contour
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "contour_certgen" {
  metadata {
    name      = "contour-certgen"
    namespace = "contour"
  }
}

