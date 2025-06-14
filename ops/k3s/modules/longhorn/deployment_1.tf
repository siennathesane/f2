# Generated from Kubernetes Deployment: longhorn-ui
# Namespace: longhorn-system
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "longhorn_ui" {
  metadata {
    name      = "longhorn-ui"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-ui"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "longhorn-ui"
      }
    }

    template {
      metadata {
        labels = {
          app                          = "longhorn-ui"
          "app.kubernetes.io/instance" = "longhorn"
          "app.kubernetes.io/name"     = "longhorn"
          "app.kubernetes.io/version"  = "v1.9.0"
        }
      }

      spec {
        volume {
          name = "nginx-cache"
          empty_dir {}
        }

        volume {
          name = "nginx-config"
          empty_dir {}
        }

        volume {
          name = "var-run"
          empty_dir {}
        }

        container {
          name  = "longhorn-ui"
          image = "longhornio/longhorn-ui:v1.9.0"

          port {
            name           = "http"
            container_port = 8000
          }

          env {
            name  = "LONGHORN_MANAGER_IP"
            value = "http://longhorn-backend:9500"
          }

          env {
            name  = "LONGHORN_UI_PORT"
            value = "8000"
          }

          volume_mount {
            name       = "nginx-cache"
            mount_path = "/var/cache/nginx/"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/var/config/nginx/"
          }

          volume_mount {
            name       = "var-run"
            mount_path = "/var/run/"
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "longhorn-ui-service-account"

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1

              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["longhorn-ui"]
                  }
                }

                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        priority_class_name = "longhorn-critical"
      }
    }
  }
}
