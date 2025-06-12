# Generated from Kubernetes Role: contour
# Namespace: contour
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role" "contour" {
  metadata {
    name      = "contour"
    namespace = "contour"
  }

  rule {
    verbs      = ["create", "get", "update"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["create", "get", "update"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

