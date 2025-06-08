output "f2-namespace" {
  value = kubernetes_namespace.f2-env.metadata[0].name
}

output "ghcr-pull-secret-name" {
  value = kubernetes_secret_v1.ghcr.metadata[0].name
}
