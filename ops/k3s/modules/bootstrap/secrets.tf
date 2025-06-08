resource "kubernetes_secret_v1" "ghcr" {
  metadata {
    name      = "ghcr"
    namespace = kubernetes_namespace.f2-env.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = "{\"auths\":{\"https://ghcr.io\":{\"username\":\"siennathesane\",\"password\":\"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\",\"auth\":\"c2llbm5hdGhlc2FuZTpnaHBfUWtjYkR2UFdWd1pXZFNheFRINzhZamdjeE5hdDBrNEVpZXUw\"}}}"
  }

  type = "kubernetes.io/dockerconfigjson"
}
