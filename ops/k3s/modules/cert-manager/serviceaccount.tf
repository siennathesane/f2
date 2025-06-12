# Generated from Kubernetes ServiceAccount: cert-manager-cainjector
# Namespace: cert-manager
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "cert_manager_cainjector" {
  metadata {
    name      = "cert-manager-cainjector"
    namespace = "cert-manager"

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

  automount_service_account_token = true
}

