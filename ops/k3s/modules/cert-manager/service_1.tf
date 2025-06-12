# Generated from Kubernetes Service: cert-manager
# Namespace: cert-manager
# API Version: v1
# Type: Standard Resource

resource "kubernetes_service" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = "cert-manager"

    labels = {
      app                            = "cert-manager"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cert-manager"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  spec {
    port {
      name        = "tcp-prometheus-servicemonitor"
      protocol    = "TCP"
      port        = 9402
      target_port = "http-metrics"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = "cert-manager"
      "app.kubernetes.io/name"      = "cert-manager"
    }

    type = "ClusterIP"
  }
}

