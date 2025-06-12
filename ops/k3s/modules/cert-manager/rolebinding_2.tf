# Generated from Kubernetes RoleBinding: cert-manager-cert-manager-tokenrequest
# Namespace: cert-manager
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role_binding" "cert_manager_cert_manager_tokenrequest" {
  metadata {
    name      = "cert-manager-cert-manager-tokenrequest"
    namespace = "cert-manager"

    labels = {
      app                            = "cert-manager"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cert-manager"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = "cert-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cert-manager-tokenrequest"
  }
}

