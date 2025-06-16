resource "kubernetes_secret_v1" "ghcr" {
  metadata {
    name      = "ghcr"
    namespace = kubernetes_namespace.f2-env.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = "${var.dockerconfigjson}"
  }

  type = "kubernetes.io/dockerconfigjson"
}
