# Generated from Kubernetes Service: envoy
# Namespace: contour
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "envoy" {
  metadata {
    name      = "envoy"
    namespace = "contour"
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "8443"
    }

    selector = {
      app = "envoy"
    }

    type = "ClusterIP"
    # external_traffic_policy = "Local"
  }
}
