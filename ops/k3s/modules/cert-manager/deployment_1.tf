# Generated from Kubernetes Deployment: cert-manager
# Namespace: cert-manager
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "cert_manager" {
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
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/instance"  = "cert-manager"
        "app.kubernetes.io/name"      = "cert-manager"
      }
    }

    template {
      metadata {
        labels = {
          app                            = "cert-manager"
          "app.kubernetes.io/component"  = "controller"
          "app.kubernetes.io/instance"   = "cert-manager"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "cert-manager"
          "app.kubernetes.io/version"    = "v1.18.0"
          "helm.sh/chart"                = "cert-manager-v1.18.0"
        }

        annotations = {
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/port"   = "9402"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        container {
          name  = "cert-manager-controller"
          image = "quay.io/jetstack/cert-manager-controller:v1.18.0"
          args  = ["--v=2", "--cluster-resource-namespace=$(POD_NAMESPACE)", "--leader-election-namespace=kube-system", "--acme-http01-solver-image=quay.io/jetstack/cert-manager-acmesolver:v1.18.0", "--max-concurrent-challenges=60"]

          port {
            name           = "http-metrics"
            container_port = 9402
            protocol       = "TCP"
          }

          port {
            name           = "http-healthz"
            container_port = 9403
            protocol       = "TCP"
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = "http-healthz"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 15
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 8
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            read_only_root_filesystem = true
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "cert-manager"

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }
  }
}

