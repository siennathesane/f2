# Generated from Kubernetes Role: contour-certgen
# Namespace: contour
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role" "contour_certgen" {
  metadata {
    name      = "contour-certgen"
    namespace = "contour"
  }

  rule {
    verbs      = ["create", "update"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

