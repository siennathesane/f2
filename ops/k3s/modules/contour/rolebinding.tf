# Generated from Kubernetes RoleBinding: contour
# Namespace: contour
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role_binding" "contour" {
  metadata {
    name      = "contour"
    namespace = "contour"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "contour-certgen"
    namespace = "contour"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "contour-certgen"
  }
}

