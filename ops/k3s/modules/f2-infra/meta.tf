resource "kubernetes_secret_v1" "f2-meta-db" {
  metadata {
    name      = "f2-meta-db-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "f2meta"
    password = random_password.f2-meta-db-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-meta-db-password" {
  length  = 16
  special = false
}

resource "kubernetes_deployment_v1" "f2-meta" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-meta-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-meta-${var.environment}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-meta-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-meta-${var.environment}"
        }
      }

      spec {
        container {
          name  = "f2-meta"
          image = "supabase/postgres-meta:v0.89.3"

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          env {
            name  = "PG_META_PORT"
            value = "8080"
          }

          env {
            name  = "PG_META_DB_HOST"
            value = "${kubectl_manifest.f2-cluster.name}-rw.${var.namespace}.svc.cluster.local"
          }

          env {
            name  = "PG_META_DB_PORT"
            value = "5432"
          }

          env {
            name  = "PG_META_DB_NAME"
            value = local.f2-control-plane-db-name
          }

          env {
            name = "PG_META_DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-db-admin.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "PG_META_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-db-admin.metadata[0].name
                key  = "password"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 30
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-meta" {
  metadata {
    name      = "f2-meta-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-meta-${var.environment}"
    }
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-meta-${var.environment}"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
