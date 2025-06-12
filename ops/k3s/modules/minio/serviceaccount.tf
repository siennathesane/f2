# Generated from Kubernetes ServiceAccount: minio-operator
# Namespace: minio-operator
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service_account" "minio_operator" {
  metadata {
    name      = "minio-operator"
    namespace = "minio-system"
  }
}
