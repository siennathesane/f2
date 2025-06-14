# Generated from Kubernetes Deployment: contour
# Namespace: contour
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "contour" {
  metadata {
    name      = "contour"
    namespace = "contour"

    labels = {
      app = "contour"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "contour"
      }
    }

    template {
      metadata {
        labels = {
          app = "contour"
        }
      }

      spec {
        volume {
          name = "contourcert"

          secret {
            secret_name = "contourcert"
          }
        }

        volume {
          name = "contour-config"

          config_map {
            name = "contour"

            items {
              key  = "contour.yaml"
              path = "contour.yaml"
            }

            default_mode = "0644"
          }
        }

        container {
          name    = "contour"
          image   = "ghcr.io/projectcontour/contour:v1.32.0"
          command = ["contour"]
          args    = ["serve", "--incluster", "--xds-address=0.0.0.0", "--xds-port=8001", "--contour-cafile=/certs/ca.crt", "--contour-cert-file=/certs/tls.crt", "--contour-key-file=/certs/tls.key", "--config-path=/config/contour.yaml"]

          port {
            name           = "xds"
            container_port = 8001
            protocol       = "TCP"
          }

          port {
            name           = "metrics"
            container_port = 8000
            protocol       = "TCP"
          }

          port {
            name           = "debug"
            container_port = 6060
            protocol       = "TCP"
          }

          env {
            name = "CONTOUR_NAMESPACE"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          volume_mount {
            name       = "contourcert"
            read_only  = true
            mount_path = "/certs"
          }

          volume_mount {
            name       = "contour-config"
            read_only  = true
            mount_path = "/config"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "8000"
            }
          }

          readiness_probe {
            tcp_socket {
              port = "8001"
            }

            period_seconds = 10
          }

          image_pull_policy = "IfNotPresent"
        }

        dns_policy           = "ClusterFirst"
        service_account_name = "contour"

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          run_as_non_root = true
        }

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100

              pod_affinity_term {
                label_selector {
                  match_labels = {
                    app = "contour"
                  }
                }

                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge = "50%"
      }
    }
  }
}
