# Generated from Kubernetes Service: sts
# Namespace: minio-operator
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "sts" {
  metadata {
    name      = "sts"
    namespace = "minio-system"
  }

  spec {
    port {
      name = "https"
      port = 4223
    }

    selector = {
      "app.kubernetes.io/instance" = "operator"
      "app.kubernetes.io/name"     = "operator"
    }

    type = "ClusterIP"
  }
}
