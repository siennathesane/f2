# Generated from Kubernetes Service: longhorn-backend
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "longhorn_backend" {
  metadata {
    name      = "longhorn-backend"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-manager"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    port {
      name        = "manager"
      port        = 9500
      target_port = "manager"
    }

    selector = {
      app = "longhorn-manager"
    }

    type = "ClusterIP"
  }
}

