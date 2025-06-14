# Generated from Kubernetes Service: longhorn-recovery-backend
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "longhorn_recovery_backend" {
  metadata {
    name      = "longhorn-recovery-backend"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-recovery-backend"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    port {
      name        = "recovery-backend"
      port        = 9503
      target_port = "recov-backend"
    }

    selector = {
      "longhorn.io/recovery-backend" = "longhorn-recovery-backend"
    }

    type = "ClusterIP"
  }
}

