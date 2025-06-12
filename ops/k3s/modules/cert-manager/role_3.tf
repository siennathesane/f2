# Generated from Kubernetes Role: cert-manager-webhook:dynamic-serving
# Namespace: cert-manager
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role" "cert_manager_webhook_dynamic_serving" {
  metadata {
    name      = "cert-manager-webhook:dynamic-serving"
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

  rule {
    verbs          = ["get", "list", "watch", "update"]
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["cert-manager-webhook-ca"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

