locals {
  f2-auth-db-namespace = "auth"
}

resource "kubernetes_service_account" "f2-auth" {
  metadata {
    name      = "f2-auth"
    namespace = var.namespace
  }
}

resource "kubernetes_manifest" "f2-auth-db" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Database"
    "metadata" = {
      "name"      = "f2-auth-db"
      "namespace" = var.namespace
    }
    "spec" = {
      "cluster" = {
        "name" = kubernetes_manifest.f2-cluster.object.metadata.name
      }
      "allowConnections" = true
      "name"             = local.f2-auth-db-namespace
      "owner"            = kubernetes_secret_v1.f2-auth-db.data.username
      "schemas" = [{
        "name"  = local.f2-auth-db-namespace
        "owner" = kubernetes_secret_v1.f2-auth-db.data.username
      }]
    }
  }
}

resource "kubernetes_config_map_v1" "f2-auth-initdb" {
  metadata {
    name      = "sql-commands"
    namespace = var.namespace
  }

  data = {
    "script.sql" = <<-EOT
    ALTER USER ${kubernetes_secret_v1.f2-auth-db.data.username} WITH LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
    GRANT ${kubernetes_secret_v1.f2-auth-db.data.username} TO postgres;
    CREATE SCHEMA IF NOT EXISTS ${local.f2-auth-db-namespace} AUTHORIZATION ${kubernetes_secret_v1.f2-auth-db.data.username};
    GRANT CREATE ON DATABASE postgres TO ${kubernetes_secret_v1.f2-auth-db.data.username};
    ALTER USER ${kubernetes_secret_v1.f2-auth-db.data.username} SET search_path = '${local.f2-auth-db-namespace}';
    EOT
  }
}

resource "kubernetes_secret_v1" "f2-auth-db" {
  metadata {
    name      = "auth-db"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "auth"
    password = random_password.f2-auth-db-password.result
    database = "auth"
  }

  type = "kubernetes.io/basic-auth"
}

resource "random_password" "f2-auth-db-password" {
  length  = 16
  special = false
}

resource "kubernetes_deployment_v1" "f2-auth" {
  depends_on = [kubernetes_manifest.f2-auth-db]

  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name = "f2-auth"
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
            value = "${kubernetes_manifest.f2-cluster.object.metadata.name}-rw"
          }

          env {
            name  = "PGPORT"
            value = "5432"
          }

          env {
            name  = "PGDATABASE"
            value = kubernetes_secret_v1.f2-auth-db.data.database
          }

          env {
            name  = "PGUSER"
            value = kubernetes_secret_v1.f2-auth-db.data.username
          }

          env {
            name  = "PGPASSWORD"
            value = kubernetes_secret_v1.f2-auth-db.data.password
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
            value = "auth"
          }
          env {
            name  = "DATABASE_URL"
            value = "postgres://${kubernetes_secret_v1.f2-auth-db.data.username}:${kubernetes_secret_v1.f2-auth-db.data.password}@${kubernetes_manifest.f2-cluster.object.metadata.name}-rw:5432/${kubernetes_secret_v1.f2-auth-db.data.database}"
          }
          env {
            name = "GOTRUE_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = "auth-jwt"
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
    name = "f2-auth-svc"
    labels = {
      "f2.pub/app" = "f2-auth-${var.environment}"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9999
      target_port = "9999"
    }

    selector = {
      "f2.pub/app" = "f2-auth-${var.environment}"
    }

    type = "ClusterIP"
  }
}
