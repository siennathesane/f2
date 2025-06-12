# Generated from Kubernetes Deployment: cert-manager-cainjector
# Namespace: cert-manager
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "cert_manager_cainjector" {
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
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "cainjector"
        "app.kubernetes.io/instance"  = "cert-manager"
        "app.kubernetes.io/name"      = "cainjector"
      }
    }

    template {
      metadata {
        labels = {
          app                            = "cainjector"
          "app.kubernetes.io/component"  = "cainjector"
          "app.kubernetes.io/instance"   = "cert-manager"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "cainjector"
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
          name  = "cert-manager-cainjector"
          image = "quay.io/jetstack/cert-manager-cainjector:v1.18.0"
          args  = ["--v=2", "--leader-election-namespace=kube-system"]

          port {
            name           = "http-metrics"
            container_port = 9402
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

        service_account_name = "cert-manager-cainjector"

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

