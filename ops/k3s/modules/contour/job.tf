# Generated from Kubernetes Job: contour-certgen-v1-32-0
# Namespace: contour
# API Version: batch/v1
# Type: Standard Resource

resource "kubernetes_job" "contour_certgen_v_1__32_0" {
  metadata {
    name      = "contour-certgen-v1-32-0"
    namespace = "contour"
  }

  spec {
    parallelism   = 1
    completions   = 1
    backoff_limit = 1

    template {
      metadata {
        labels = {
          app = "contour-certgen"
        }
      }

      spec {
        container {
          name    = "contour"
          image   = "ghcr.io/projectcontour/contour:v1.32.0"
          command = ["contour", "certgen", "--kube", "--incluster", "--overwrite", "--secrets-format=compact", "--namespace=$(CONTOUR_NAMESPACE)"]

          env {
            name = "CONTOUR_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        restart_policy       = "Never"
        service_account_name = "contour-certgen"

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          run_as_non_root = true
        }
      }
    }
  }
}

