# Generated from Kubernetes RoleBinding: cert-manager-startupapicheck:create-cert
# Namespace: cert-manager
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role_binding" "cert_manager_startupapicheck_create_cert" {
  metadata {
    name      = "cert-manager-startupapicheck:create-cert"
    namespace = "cert-manager"

    labels = {
      app                            = "startupapicheck"
      "app.kubernetes.io/component"  = "startupapicheck"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "startupapicheck"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }

    annotations = {
      "helm.sh/hook"               = "post-install"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
      "helm.sh/hook-weight"        = "-5"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager-startupapicheck"
    namespace = "cert-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cert-manager-startupapicheck:create-cert"
  }
}

