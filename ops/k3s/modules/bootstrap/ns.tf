resource "kubernetes_namespace" "f2-env" {
  metadata {
    name = var.environment
  }
}

resource "kubernetes_namespace" "cert_manager_system" {
  metadata {
    name = "cert-manager"

    labels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
  }
}

resource "kubernetes_namespace" "cnpg_system" {
  metadata {
    name = "cnpg-system"

    labels = {
      "app.kubernetes.io/name" = "cloudnative-pg"
    }
  }
}

resource "kubernetes_namespace" "contour" {
  metadata {
    name = "contour"
  }
}
