# Generated from Kubernetes Service: cnpg-webhook-service
# Namespace: cnpg-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "cnpg_webhook_service" {
  metadata {
    name      = "cnpg-webhook-service"
    namespace = "cnpg-system"

    labels = {
      "app.kubernetes.io/instance"   = "cnpg"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudnative-pg"
      "app.kubernetes.io/version"    = "1.26.0"
      "helm.sh/chart"                = "cloudnative-pg-0.24.0"
    }
  }

  spec {
    port {
      name        = "webhook-server"
      port        = 443
      target_port = "webhook-server"
    }

    selector = {
      "app.kubernetes.io/instance" = "cnpg"
      "app.kubernetes.io/name"     = "cloudnative-pg"
    }

    type = "ClusterIP"
  }
}

