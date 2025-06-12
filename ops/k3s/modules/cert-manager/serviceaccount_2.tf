# Generated from Kubernetes ServiceAccount: cert-manager-webhook
# Namespace: cert-manager
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "cert_manager_webhook" {
  metadata {
    name      = "cert-manager-webhook"
    namespace = "cert-manager"

    labels = {
      app                            = "webhook"
      "app.kubernetes.io/component"  = "webhook"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "webhook"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  automount_service_account_token = true
}

