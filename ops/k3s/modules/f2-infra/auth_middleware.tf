resource "kubernetes_deployment" "f2-auth-middleware" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-auth-middleware-${var.environment}"
    namespace = var.namespace

    labels = {
      "f2.pub/app" = "f2-auth-middlware-${var.environment}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-auth-middlware-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-auth-middlware-${var.environment}"
        }
      }

      spec {
        image_pull_secrets { name = var.ghcr-pull-secret-name }

        container {
          name              = "f2-auth-middleware"
          image             = "ghcr.io/siennathesane/f2/auth-svc:latest"
          image_pull_policy = "Always"

          port {
            name           = "http"
            container_port = 8080
          }

          env {
            name = "JWT_SECRET"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name = "DASHBOARD_USERNAME"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-dashboard-creds.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "DASHBOARD_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-dashboard-creds.metadata[0].name
                key  = "password"
              }
            }
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }

            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }

            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-auth-middleware" {
  metadata {
    name      = "f2-auth-middlware-${var.environment}"
    namespace = var.namespace

    labels = {
      "f2.pub/app" = "f2-auth-middlware-${var.environment}"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }

    selector = {
      "f2.pub/app" = "f2-auth-middlware-${var.environment}"
    }

    type = "ClusterIP"
  }
}
