# Generated from Kubernetes Job: cert-manager-startupapicheck
# Namespace: cert-manager
# API Version: batch/v1
# Type: Standard Resource

resource "kubernetes_job" "cert_manager_startupapicheck" {
  depends_on = [kubernetes_service_account.cert_manager_startupapicheck]

  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "cert-manager-startupapicheck"
    namespace = "cert-manager"

    labels = {
      app                            = "startupapicheck"
      "app.kubernetes.io/component"  = "startupapicheck"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "startupapicheck"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }

    annotations = {
      "helm.sh/hook"               = "post-install"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
      "helm.sh/hook-weight"        = "1"
    }
  }

  spec {
    backoff_limit = 4

    template {
      metadata {
        labels = {
          app                            = "startupapicheck"
          "app.kubernetes.io/component"  = "startupapicheck"
          "app.kubernetes.io/instance"   = "cert-manager"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "startupapicheck"
          "app.kubernetes.io/version"    = "v1.18.0"
          "helm.sh/chart"                = "cert-manager-v1.18.0"
        }
      }

      spec {
        container {
          name  = "cert-manager-startupapicheck"
          image = "quay.io/jetstack/cert-manager-startupapicheck:v1.18.0"
          args  = ["check", "api", "--wait=1m", "-v"]

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

        restart_policy = "OnFailure"

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "cert-manager-startupapicheck"

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
