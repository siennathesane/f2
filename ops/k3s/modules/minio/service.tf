# Generated from Kubernetes Service: operator
# Namespace: minio-operator
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "operator" {
  metadata {
    name      = "operator"
    namespace = "minio-system"
  }

  spec {
    port {
      name = "http"
      port = 4221
    }

    selector = {
      "app.kubernetes.io/instance" = "operator"
      "app.kubernetes.io/name"     = "operator"
      operator                     = "leader"
    }

    type = "ClusterIP"
  }
}
