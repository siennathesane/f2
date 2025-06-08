resource "kubernetes_namespace" "f2-env" {
  metadata {
    name = var.environment
  }
}
