# Generated from Kubernetes DaemonSet: envoy
# Namespace: contour
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_daemonset" "envoy" {
  metadata {
    name      = "envoy"
    namespace = "contour"

    labels = {
      app = "envoy"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "envoy"
      }
    }

    template {
      metadata {
        labels = {
          app = "envoy"
        }
      }

      spec {
        volume {
          name = "envoy-admin"
          empty_dir {

          }
        }

        volume {
          name = "envoy-config"
          empty_dir {

          }
        }

        volume {
          name = "envoycert"

          secret {
            secret_name = "envoycert"
          }
        }

        init_container {
          name    = "envoy-initconfig"
          image   = "ghcr.io/projectcontour/contour:v1.32.0"
          command = ["contour"]
          args    = ["bootstrap", "/config/envoy.json", "--xds-address=contour", "--xds-port=8001", "--xds-resource-version=v3", "--resources-dir=/config/resources", "--envoy-cafile=/certs/ca.crt", "--envoy-cert-file=/certs/tls.crt", "--envoy-key-file=/certs/tls.key"]

          env {
            name = "CONTOUR_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            name       = "envoy-config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "envoycert"
            read_only  = true
            mount_path = "/certs"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name    = "shutdown-manager"
          image   = "ghcr.io/projectcontour/contour:v1.32.0"
          command = ["/bin/contour"]
          args    = ["envoy", "shutdown-manager"]

          volume_mount {
            name       = "envoy-admin"
            mount_path = "/admin"
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/contour", "envoy", "shutdown"]
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name    = "envoy"
          image   = "docker.io/envoyproxy/envoy:v1.34.1"
          command = ["envoy"]
          args    = ["-c", "/config/envoy.json", "--service-cluster $(CONTOUR_NAMESPACE)", "--service-node $(ENVOY_POD_NAME)", "--log-level info"]

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 8443
            protocol       = "TCP"
          }

          port {
            name           = "metrics"
            host_port      = 8002
            container_port = 8002
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
            name = "ENVOY_POD_NAME"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          volume_mount {
            name       = "envoy-config"
            read_only  = true
            mount_path = "/config"
          }

          volume_mount {
            name       = "envoycert"
            read_only  = true
            mount_path = "/certs"
          }

          volume_mount {
            name       = "envoy-admin"
            mount_path = "/admin"
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "8002"
            }

            initial_delay_seconds = 3
            period_seconds        = 4
          }

          lifecycle {
            pre_stop {
              http_get {
                path   = "/shutdown"
                port   = "8090"
                scheme = "HTTP"
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 300
        service_account_name             = "envoy"

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          run_as_non_root = true
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "10%"
      }
    }
  }
}
