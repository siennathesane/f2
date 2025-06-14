# Generated from Kubernetes Deployment: cnpg-cloudnative-pg
# Namespace: cnpg-system
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "cnpg_cloudnative_pg" {
  metadata {
    name      = "cnpg-cloudnative-pg"
    namespace = "cnpg-system"

    labels = {
      "app.kubernetes.io/instance"   = "cnpg"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudnative-pg"
      "app.kubernetes.io/version"    = "1.26.0"
      "helm.sh/chart"                = "cloudnative-pg-0.24.0"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "cnpg"
        "app.kubernetes.io/name"     = "cloudnative-pg"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/instance" = "cnpg"
          "app.kubernetes.io/name"     = "cloudnative-pg"
        }

        annotations = {
          "checksum/config"            = "b9237dbc244ee5efe8baa1d10c3a6cbd9b52ef95f4ab78b5118b274c39ffd8ce"
          "checksum/monitoring-config" = "655cb80af844592951cf6b828dfea17fd5a7b9f24e72763b9607d7ef03a51f1d"
          "checksum/rbac"              = "e2782c26570f196e5d27d767f1b6ea78c7aac8cf3f3b65e675142eb15d3a8f77"
        }
      }

      spec {
        volume {
          name = "scratch-data"
          empty_dir {

          }
        }

        volume {
          name = "webhook-certificates"

          secret {
            secret_name  = "cnpg-webhook-cert"
            default_mode = "0644"
            optional     = true
          }
        }

        container {
          name    = "manager"
          image   = "ghcr.io/cloudnative-pg/cloudnative-pg:1.26.0"
          command = ["/manager"]
          args    = ["controller", "--leader-elect", "--max-concurrent-reconciles=10", "--config-map-name=cnpg-controller-manager-config", "--webhook-port=9443"]

          port {
            name           = "metrics"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "webhook-server"
            container_port = 9443
            protocol       = "TCP"
          }

          env {
            name  = "OPERATOR_IMAGE_NAME"
            value = "ghcr.io/cloudnative-pg/cloudnative-pg:1.26.0"
          }

          env {
            name = "OPERATOR_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "MONITORING_QUERIES_CONFIGMAP"
            value = "cnpg-default-monitoring"
          }

          volume_mount {
            name       = "scratch-data"
            mount_path = "/controller"
          }

          volume_mount {
            name       = "webhook-certificates"
            mount_path = "/run/secrets/cnpg.io/webhook"
          }

          liveness_probe {
            http_get {
              path   = "/readyz"
              port   = "9443"
              scheme = "HTTPS"
            }

            initial_delay_seconds = 3
          }

          readiness_probe {
            http_get {
              path   = "/readyz"
              port   = "9443"
              scheme = "HTTPS"
            }

            initial_delay_seconds = 3
          }

          startup_probe {
            http_get {
              path   = "/readyz"
              port   = "9443"
              scheme = "HTTPS"
            }

            period_seconds    = 5
            failure_threshold = 6
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 10001
            run_as_group              = 10001
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        termination_grace_period_seconds = 10
        service_account_name             = "cnpg-cloudnative-pg"

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
