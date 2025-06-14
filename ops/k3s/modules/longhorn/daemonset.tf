# Generated from Kubernetes DaemonSet: longhorn-manager
# Namespace: longhorn-system
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_daemonset" "longhorn_manager" {
  metadata {
    name      = "longhorn-manager"
    namespace = "longhorn-system"

    labels = {
      app                          = "longhorn-manager"
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "longhorn-manager"
      }
    }

    template {
      metadata {
        labels = {
          app                          = "longhorn-manager"
          "app.kubernetes.io/instance" = "longhorn"
          "app.kubernetes.io/name"     = "longhorn"
          "app.kubernetes.io/version"  = "v1.9.0"
        }
      }

      spec {
        volume {
          name = "boot"

          host_path {
            path = "/boot/"
          }
        }

        volume {
          name = "dev"

          host_path {
            path = "/dev/"
          }
        }

        volume {
          name = "proc"

          host_path {
            path = "/proc/"
          }
        }

        volume {
          name = "etc"

          host_path {
            path = "/etc/"
          }
        }

        volume {
          name = "longhorn"

          host_path {
            path = "/var/lib/longhorn/"
          }
        }

        volume {
          name = "longhorn-grpc-tls"

          secret {
            secret_name = "longhorn-grpc-tls"
            optional    = true
          }
        }

        container {
          name    = "longhorn-manager"
          image   = "longhornio/longhorn-manager:v1.9.0"
          command = ["longhorn-manager", "-d", "daemon", "--engine-image", "longhornio/longhorn-engine:v1.9.0", "--instance-manager-image", "longhornio/longhorn-instance-manager:v1.9.0", "--share-manager-image", "longhornio/longhorn-share-manager:v1.9.0", "--backing-image-manager-image", "longhornio/backing-image-manager:v1.9.0", "--support-bundle-manager-image", "longhornio/support-bundle-kit:v0.0.55", "--manager-image", "longhornio/longhorn-manager:v1.9.0", "--service-account", "longhorn-service-account", "--upgrade-version-check"]

          port {
            name           = "manager"
            container_port = 9500
          }

          port {
            name           = "conversion-wh"
            container_port = 9501
          }

          port {
            name           = "admission-wh"
            container_port = 9502
          }

          port {
            name           = "recov-backend"
            container_port = 9503
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name       = "boot"
            read_only  = true
            mount_path = "/host/boot/"
          }

          volume_mount {
            name       = "dev"
            mount_path = "/host/dev/"
          }

          volume_mount {
            name       = "proc"
            read_only  = true
            mount_path = "/host/proc/"
          }

          volume_mount {
            name       = "etc"
            read_only  = true
            mount_path = "/host/etc/"
          }

          volume_mount {
            name              = "longhorn"
            mount_path        = "/var/lib/longhorn/"
            mount_propagation = "Bidirectional"
          }

          volume_mount {
            name       = "longhorn-grpc-tls"
            mount_path = "/tls-files/"
          }

          readiness_probe {
            http_get {
              path   = "/v1/healthz"
              port   = "9501"
              scheme = "HTTPS"
            }
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            privileged = true
          }
        }

        container {
          name              = "pre-pull-share-manager-image"
          image             = "longhornio/longhorn-share-manager:v1.9.0"
          command           = ["sh", "-c", "echo share-manager image pulled && sleep infinity"]
          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "longhorn-service-account"
        priority_class_name  = "longhorn-critical"
      }
    }

    strategy {
      rolling_update {
        max_unavailable = "100%"
      }
    }
  }
}

