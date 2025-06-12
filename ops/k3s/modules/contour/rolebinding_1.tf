# Generated from Kubernetes RoleBinding: contour-rolebinding
# Namespace: contour
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role_binding" "contour_rolebinding" {
  metadata {
    name      = "contour-rolebinding"
    namespace = "contour"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "contour"
    namespace = "contour"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "contour"
  }
}

