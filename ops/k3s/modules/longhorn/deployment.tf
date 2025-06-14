# Generated from Kubernetes Deployment: longhorn-driver-deployer
# Namespace: longhorn-system
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "longhorn_driver_deployer" {
  metadata {
    name      = "longhorn-driver-deployer"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "longhorn-driver-deployer"
      }
    }

    template {
      metadata {
        labels = {
          app                          = "longhorn-driver-deployer"
          "app.kubernetes.io/instance" = "longhorn"
          "app.kubernetes.io/name"     = "longhorn"
          "app.kubernetes.io/version"  = "v1.9.0"
        }
      }

      spec {
        init_container {
          name    = "wait-longhorn-manager"
          image   = "longhornio/longhorn-manager:v1.9.0"
          command = ["sh", "-c", "while [ $(curl -m 1 -s -o /dev/null -w \"%%{http_code}\" http://longhorn-backend:9500/v1) != \"200\" ]; do echo waiting; sleep 2; done"]
        }

        container {
          name    = "longhorn-driver-deployer"
          image   = "longhornio/longhorn-manager:v1.9.0"
          command = ["longhorn-manager", "-d", "deploy-driver", "--manager-image", "longhornio/longhorn-manager:v1.9.0", "--manager-url", "http://longhorn-backend:9500/v1"]

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
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

          env {
            name = "SERVICE_ACCOUNT"

            value_from {
              field_ref {
                field_path = "spec.serviceAccountName"
              }
            }
          }

          env {
            name  = "CSI_ATTACHER_IMAGE"
            value = "longhornio/csi-attacher:v4.8.1"
          }

          env {
            name  = "CSI_PROVISIONER_IMAGE"
            value = "longhornio/csi-provisioner:v5.2.0"
          }

          env {
            name  = "CSI_NODE_DRIVER_REGISTRAR_IMAGE"
            value = "longhornio/csi-node-driver-registrar:v2.13.0"
          }

          env {
            name  = "CSI_RESIZER_IMAGE"
            value = "longhornio/csi-resizer:v1.13.2"
          }

          env {
            name  = "CSI_SNAPSHOTTER_IMAGE"
            value = "longhornio/csi-snapshotter:v8.2.0"
          }

          env {
            name  = "CSI_LIVENESS_PROBE_IMAGE"
            value = "longhornio/livenessprobe:v2.15.0"
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "longhorn-service-account"

        security_context {
          run_as_user = 0
        }

        priority_class_name = "longhorn-critical"
      }
    }
  }
}

