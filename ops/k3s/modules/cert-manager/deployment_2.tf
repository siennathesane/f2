# Generated from Kubernetes Deployment: cert-manager-webhook
# Namespace: cert-manager
# API Version: apps/v1
# Type: Standard Resource

resource "kubernetes_deployment" "cert_manager_webhook" {
  metadata {
    name      = "cert-manager-webhook"
    namespace = "cert-manager"

    labels = {
      app                            = "webhook"
      "app.kubernetes.io/component"  = "webhook"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "webhook"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "webhook"
        "app.kubernetes.io/instance"  = "cert-manager"
        "app.kubernetes.io/name"      = "webhook"
      }
    }

    template {
      metadata {
        labels = {
          app                            = "webhook"
          "app.kubernetes.io/component"  = "webhook"
          "app.kubernetes.io/instance"   = "cert-manager"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "webhook"
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
          name  = "cert-manager-webhook"
          image = "quay.io/jetstack/cert-manager-webhook:v1.18.0"
          args  = ["--v=2", "--secure-port=10250", "--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)", "--dynamic-serving-ca-secret-name=cert-manager-webhook-ca", "--dynamic-serving-dns-names=cert-manager-webhook", "--dynamic-serving-dns-names=cert-manager-webhook.$(POD_NAMESPACE)", "--dynamic-serving-dns-names=cert-manager-webhook.$(POD_NAMESPACE).svc"]

          port {
            name           = "https"
            container_port = 10250
            protocol       = "TCP"
          }

          port {
            name           = "healthcheck"
            container_port = 6080
            protocol       = "TCP"
          }

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

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = "healthcheck"
              scheme = "HTTP"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "healthcheck"
              scheme = "HTTP"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 1
            period_seconds        = 5
            success_threshold     = 1
            failure_threshold     = 3
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

        service_account_name = "cert-manager-webhook"

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

