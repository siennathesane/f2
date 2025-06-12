# Generated from Kubernetes Deployment: minio-operator
# Namespace: minio-operator
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "minio_operator" {
  metadata {
    name      = "minio-operator"
    namespace = "minio-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "operator"
        "app.kubernetes.io/name"     = "operator"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/instance" = "operator"
          "app.kubernetes.io/name"     = "operator"
        }
      }

      spec {
        container {
          name  = "operator"
          image = "quay.io/minio/operator:v7.1.1"
          args  = ["controller"]

          env {
            name  = "OPERATOR_STS_ENABLED"
            value = "on"
          }

          resources {
            requests = {
              cpu               = "200m"
              ephemeral-storage = "500Mi"
              memory            = "256Mi"
            }
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user     = 1000
            run_as_group    = 1000
            run_as_non_root = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        service_account_name = "minio-operator"

        security_context {
          run_as_user     = 1000
          run_as_group    = 1000
          run_as_non_root = true
          fs_group        = 1000
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "name"
                  operator = "In"
                  values   = ["minio-operator"]
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }
  }
}
