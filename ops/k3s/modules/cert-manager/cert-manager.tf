resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.17.2"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }
}
