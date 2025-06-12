# Generated from Kubernetes Service: contour
# Namespace: contour
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "contour" {
  metadata {
    name      = "contour"
    namespace = "contour"
  }

  spec {
    port {
      name        = "xds"
      protocol    = "TCP"
      port        = 8001
      target_port = "8001"
    }

    selector = {
      app = "contour"
    }

    type = "ClusterIP"
  }
}

