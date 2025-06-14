# Generated from Kubernetes Service: longhorn-conversion-webhook
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "longhorn_conversion_webhook" {
  metadata {
    name      = "longhorn-conversion-webhook"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-conversion-webhook"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    port {
      name        = "conversion-webhook"
      port        = 9501
      target_port = "conversion-wh"
    }

    selector = {
      "longhorn.io/conversion-webhook" = "longhorn-conversion-webhook"
    }

    type = "ClusterIP"
  }
}

