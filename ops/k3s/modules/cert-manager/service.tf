# Generated from Kubernetes Service: cert-manager-cainjector
# Namespace: cert-manager
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "cert_manager_cainjector" {
  metadata {
    name      = "cert-manager-cainjector"
    namespace = "cert-manager"

    labels = {
      app                            = "cainjector"
      "app.kubernetes.io/component"  = "cainjector"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cainjector"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  spec {
    port {
      name     = "http-metrics"
      protocol = "TCP"
      port     = 9402
    }

    selector = {
      "app.kubernetes.io/component" = "cainjector"
      "app.kubernetes.io/instance"  = "cert-manager"
      "app.kubernetes.io/name"      = "cainjector"
    }

    type = "ClusterIP"
  }
}

