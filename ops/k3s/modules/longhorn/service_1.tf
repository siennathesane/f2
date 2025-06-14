# Generated from Kubernetes Service: longhorn-frontend
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "longhorn_frontend" {
  metadata {
    name      = "longhorn-frontend"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-ui"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }

    selector = {
      app = "longhorn-ui"
    }

    type = "ClusterIP"
  }
}

