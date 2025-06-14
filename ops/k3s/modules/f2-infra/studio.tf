resource "kubernetes_secret_v1" "f2-dashboard-creds" {
  metadata {
    name      = "f2-dashboard-creds"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "dashboard"
    password = random_password.f2-dashboard-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-dashboard-password" {
  length  = 16
  special = false
}


resource "kubernetes_secret_v1" "f2-studio-config" {
  metadata {
    name      = "f2-studio-config-${var.environment}"
    namespace = var.namespace
  }

  data = {
    # todo(siennathesane): fix this
    postgres_password             = kubernetes_secret_v1.f2-db-admin.data.password
    openai_api_key                = "" # Add your OpenAI API key here if needed
    anonKey                       = kubernetes_secret_v1.f2-auth-jwt.data.anonKey
    serviceKey                    = kubernetes_secret_v1.f2-auth-jwt.data.serviceKey
    secret                        = kubernetes_secret_v1.f2-auth-jwt.data.secret
    logflare_private_access_token = kubernetes_secret_v1.f2-analytics-config.data.private_api_key
    dashboard_user                = kubernetes_secret_v1.f2-dashboard-creds.data.username
    dashboard_password            = kubernetes_secret_v1.f2-dashboard-creds.data.password
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "f2-studio-config" {
  metadata {
    name      = "f2-studio-config-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-studio-${var.environment}"
    }
  }

  data = {
    STUDIO_PG_META_URL              = "http://${kubernetes_service_v1.f2-meta.metadata[0].name}.${var.namespace}.svc.cluster.local:8080"
    DEFAULT_ORGANIZATION_NAME       = "f2"
    DEFAULT_PROJECT_NAME            = "f2-${var.environment}"
    SUPABASE_URL                    = "http://${kubernetes_service_v1.f2-control-plane.metadata[0].name}.${var.namespace}.svc.cluster.local"
    SUPABASE_PUBLIC_URL             = "http://${var.public-url}"
    NEXT_PUBLIC_SUPABASE_URL        = "http://${var.public-url}"
    LOGFLARE_URL                    = "http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.${var.namespace}.svc.cluster.local:4000"
    NEXT_PUBLIC_ENABLE_LOGS         = "true"
    NEXT_ANALYTICS_BACKEND_PROVIDER = "postgres"
  }
}

resource "kubernetes_deployment_v1" "f2-studio" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-studio-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-studio-${var.environment}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-studio-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-studio-${var.environment}"
        }
      }

      spec {
        image_pull_secrets { name = var.ghcr-pull-secret-name }
        container {
          name              = "f2-studio"
          image             = "ghcr.io/siennathesane/f2/studio:latest"
          image_pull_policy = "Always"

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }

          env {
            name  = "HOSTNAME"
            value = "0.0.0.0"
          }

          # Environment variables from ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.f2-studio-config.metadata[0].name
            }
          }

          env {
            name = "DASHBOARD_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "dashboard_user"
              }
            }
          }

          env {
            name = "DASHBOARD_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "dashboard_password"
              }
            }
          }

          # Sensitive environment variables from Secret
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "postgres_password"
              }
            }
          }

          env {
            name = "OPENAI_API_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "openai_api_key"
              }
            }
          }

          env {
            name = "SUPABASE_ANON_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "anonKey"
              }
            }
          }

          env {
            name = "SUPABASE_SERVICE_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "serviceKey"
              }
            }
          }

          env {
            name = "AUTH_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name = "LOGFLARE_PRIVATE_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-studio-config.metadata[0].name
                key  = "logflare_private_access_token"
              }
            }
          }

          #   liveness_probe {
          #     exec {
          #       command = [
          #         "node",
          #         "-e",
          #         "fetch('http://localhost:3000/api/platform/profile').then((r) => {if (r.status !== 200) throw new Error(r.status)})"
          #       ]
          #     }
          #     initial_delay_seconds = 30
          #     timeout_seconds       = 10
          #     period_seconds        = 30
          #     failure_threshold     = 3
          #   }

          #   readiness_probe {
          #     exec {
          #       command = [
          #         "node",
          #         "-e",
          #         "fetch('http://localhost:3000/api/platform/profile').then((r) => {if (r.status !== 200) throw new Error(r.status)})"
          #       ]
          #     }
          #     initial_delay_seconds = 10
          #     timeout_seconds       = 10
          #     period_seconds        = 10
          #     failure_threshold     = 3
          #   }

          #   startup_probe {
          #     exec {
          #       command = [
          #         "node",
          #         "-e",
          #         "fetch('http://localhost:3000/api/platform/profile').then((r) => {if (r.status !== 200) throw new Error(r.status)})"
          #       ]
          #     }
          #     initial_delay_seconds = 5
          #     timeout_seconds       = 10
          #     period_seconds        = 5
          #     failure_threshold     = 12
          #   }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-studio" {
  metadata {
    name      = "f2-studio-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-studio-${var.environment}"
    }
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-studio-${var.environment}"
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_v1" "f2-control-plane" {
  metadata {
    name      = "f2-${var.environment}"
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "80"
    }

    type          = "ExternalName"
    external_name = "envoy.contour.svc.cluster.local"
  }
}
