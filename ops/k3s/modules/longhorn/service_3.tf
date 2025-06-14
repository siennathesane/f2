# Generated from Kubernetes Service: longhorn-admission-webhook
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "longhorn_admission_webhook" {
  metadata {
    name      = "longhorn-admission-webhook"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-admission-webhook"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    port {
      name        = "admission-webhook"
      port        = 9502
      target_port = "admission-wh"
    }

    selector = {
      "longhorn.io/admission-webhook" = "longhorn-admission-webhook"
    }

    type = "ClusterIP"
  }
}

