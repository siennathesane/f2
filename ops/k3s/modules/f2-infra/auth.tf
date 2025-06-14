locals {
  f2-auth-db-namespace = "auth"
}

resource "kubernetes_service_account" "f2-auth" {
  metadata {
    name      = "f2-auth-${var.environment}"
    namespace = var.namespace
  }
}

resource "kubernetes_config_map_v1" "f2-auth-initdb" {
  metadata {
    name      = "f2-auth-initdb-sql-commands-${var.environment}"
    namespace = var.namespace
  }

  data = {
    "script.sql" = <<-EOT
    ALTER USER ${kubernetes_secret_v1.f2-auth-config.data.username} WITH LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
    GRANT ${kubernetes_secret_v1.f2-auth-config.data.username} TO postgres;
    CREATE SCHEMA IF NOT EXISTS ${local.f2-auth-db-namespace} AUTHORIZATION ${kubernetes_secret_v1.f2-auth-config.data.username};
    GRANT CREATE ON DATABASE postgres TO ${kubernetes_secret_v1.f2-auth-config.data.username};
    ALTER USER ${kubernetes_secret_v1.f2-auth-config.data.username} SET search_path = '${local.f2-auth-db-namespace}';
    EOT
  }
}

resource "kubernetes_secret_v1" "f2-auth-config" {
  metadata {
    name      = "f2-auth-db-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "f2auth"
    password = random_password.f2-auth-db-password.result
  }

  type = "kubernetes.io/basic-auth"
}

# to prevent cyles
resource "kubernetes_secret_v1" "f2-auth-db-uri" {
  metadata {
    name      = "f2-auth-db-uri-${var.environment}"
    namespace = var.namespace
  }

  data = {
    db_uri = "postgres://${kubernetes_secret_v1.f2-auth-config.data.username}:${kubernetes_secret_v1.f2-auth-config.data.password}@${kubectl_manifest.f2-cluster.name}-rw:5432/${local.f2-control-plane-db-name}"
  }
}

resource "random_password" "f2-auth-db-password" {
  length  = 16
  special = false
}

resource "kubernetes_deployment_v1" "f2-auth" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name = "f2-auth-${var.environment}"
    labels = {
      "f2.pub/app" = "f2-auth-${var.environment}"
    }
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-auth-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-auth-${var.environment}"
        }
      }

      spec {
        image_pull_secrets { name = var.ghcr-pull-secret-name }

        init_container {
          name    = "init-db"
          image   = "postgres:17-alpine"
          command = ["psql", "-f", "/sql/script.sql"]

          env {
            name  = "PGHOST"
            value = "${kubectl_manifest.f2-cluster.name}-rw"
          }

          env {
            name  = "PGPORT"
            value = "5432"
          }

          env {
            name  = "PGDATABASE"
            value = local.f2-control-plane-db-name
          }

          env {
            name = "PGUSER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-db-admin.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-db-admin.metadata[0].name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "sql-volume"
            mount_path = "/sql"
          }
        }

        volume {
          name = "sql-volume"

          config_map {
            name = kubernetes_config_map_v1.f2-auth-initdb.metadata[0].name
          }
        }

        container {
          image             = "ghcr.io/siennathesane/auth:${var.goauth-version}"
          image_pull_policy = "Always"
          name              = "auth"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          port {
            name           = "http"
            container_port = 9999
            protocol       = "TCP"
          }

          env {
            name  = "GOTRUE_DB_DRIVER"
            value = "postgres"
          }
          env {
            name  = "DB_NAMESPACE"
            value = local.f2-auth-db-namespace
          }
          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-db-uri.metadata[0].name
                key  = "db_uri"
              }
            }
          }
          env {
            name = "GOTRUE_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }
          env {
            name  = "API_EXTERNAL_URL"
            value = "http://${var.public-url}"
          }

          env {
            name  = "GOTRUE_SITE_URL"
            value = "http://${var.public-url}"
          }

          env {
            name  = "GOTRUE_API_HOST"
            value = "0.0.0.0"
          }
          env {
            name  = "PORT"
            value = "9999"
          }

          # liveness_probe {
          #   http_get {
          #     path = "/"
          #     port = 9999

          #     http_header {
          #       name  = "X-Custom-Header"
          #       value = "Awesome"
          #     }
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds        = 3
          # }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-auth-svc" {
  metadata {
    name      = "f2-auth-svc-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-auth-${var.environment}"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9999
      target_port = 9999
    }

    selector = {
      "f2.pub/app" = "f2-auth-${var.environment}"
    }

    type = "ClusterIP"
  }
}
