# Generated from Kubernetes ServiceAccount: cert-manager-startupapicheck
# Namespace: cert-manager
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "cert_manager_startupapicheck" {
  metadata {
    name      = "cert-manager-startupapicheck"
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

  automount_service_account_token = true
}

