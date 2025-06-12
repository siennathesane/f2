# Generated from Kubernetes Service: cert-manager-webhook
# Namespace: cert-manager
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "cert_manager_webhook" {
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

  spec {
    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "https"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 9402
      target_port = "http-metrics"
    }

    selector = {
      "app.kubernetes.io/component" = "webhook"
      "app.kubernetes.io/instance"  = "cert-manager"
      "app.kubernetes.io/name"      = "webhook"
    }

    type = "ClusterIP"
  }
}

