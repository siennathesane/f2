# Generated from Kubernetes RoleBinding: cert-manager-cainjector:leaderelection
# Namespace: kube-system
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role_binding" "cert_manager_cainjector_leaderelection" {
  metadata {
    name      = "cert-manager-cainjector:leaderelection"
    namespace = "kube-system"

    labels = {
      app                            = "cainjector"
      "app.kubernetes.io/component"  = "cainjector"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cainjector"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager-cainjector"
    namespace = "cert-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cert-manager-cainjector:leaderelection"
  }
}

