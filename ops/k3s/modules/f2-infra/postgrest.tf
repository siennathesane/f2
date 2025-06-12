locals {
  # a list of all available schemas for postgrest to view
  f2-postgrest-schemas = join(",", [
    "public",
    local.f2-analytics-db-namespace,
    local.f2-auth-db-namespace,
    "graphql_public",
    local.f2-realtime-db-namespace
  ])
}

resource "kubernetes_secret_v1" "f2-postgrest-creds" {
  metadata {
    name      = "f2-postgrest-creds-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username      = "f2postgrestauth"
    password      = random_password.f2-postgrest-password.result
    anon_username = "f2postgrestanon"
    web_username  = "f2postgrestweb"
    schemas       = local.f2-postgrest-schemas
  }

  type = "Opaque"
}

resource "random_password" "f2-postgrest-password" {
  length  = 16
  special = false
}

# this is just to prevent cycles
resource "kubernetes_secret_v1" "f2-postgrest-db-uri" {
  metadata {
    name      = "fw-postgres-db-uri-${var.environment}"
    namespace = var.namespace
  }

  data = {
    db_uri = "postgresql://${kubernetes_secret_v1.f2-postgrest-creds.data.username}:${kubernetes_secret_v1.f2-postgrest-creds.data.password}@${kubectl_manifest.f2-cluster.name}-rw.${var.environment}.svc.cluster.local:5432/${local.f2-control-plane-db-name}?sslmode=disable"
  }
}

resource "kubernetes_config_map_v1" "f2-postgrest-initdb" {
  metadata {
    name      = "f2-postgrest-initdb-sql-commands-${var.environment}"
    namespace = var.namespace
  }

  data = {
    "script.sql" = <<-EOT
    ALTER ROLE ${kubernetes_secret_v1.f2-postgrest-creds.data.username} NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER;
    GRANT ${kubernetes_secret_v1.f2-postgrest-creds.data.anon_username} TO ${kubernetes_secret_v1.f2-postgrest-creds.data.username};
    GRANT ${kubernetes_secret_v1.f2-postgrest-creds.data.web_username} TO ${kubernetes_secret_v1.f2-postgrest-creds.data.username};
    EOT
  }
}

resource "kubernetes_deployment_v1" "f2-postgrest" {
  metadata {
    name      = "f2-postgrest-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-postgrest-${var.environment}"
    }
  }

  timeouts {
    create = "2m"
    update = "2m"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-postgrest-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-postgrest-${var.environment}"
        }
      }

      spec {
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
            value = "bootstrap"
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
            name = kubernetes_config_map_v1.f2-postgrest-initdb.metadata[0].name
          }
        }

        container {
          name  = "f2-postgrest"
          image = "postgrest/postgrest:v12.2.12"

          env {
            name = "PGRST_DB_URI"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-postgrest-db-uri.metadata[0].name
                key  = "db_uri"
              }
            }
          }

          env {
            name = "PGRST_DB_SCHEMAS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-postgrest-creds.metadata[0].name
                key  = "schemas"
              }
            }
          }

          env {
            name = "PGRST_DB_ANON_ROLE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-postgrest-creds.metadata[0].name
                key  = "anon_username"
              }
            }
          }

          env {
            name = "PGRST_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name = "PGRST_APP_SETTINGS_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name = "PGRST_APP_SETTINGS_JWT_EXP"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "expiry"
              }
            }
          }

          env {
            name  = "PGRST_DB_USE_LEGACY_GUCS"
            value = "false"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }

            timeout_seconds   = 5
            period_seconds    = 5
            failure_threshold = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
          }

          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "f2-postgrest" {
  metadata {
    name      = "f2-postgrest-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-postgrest-${var.environment}"
    }
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-postgrest-${var.environment}"
    }


    port {
      name        = "http"
      port        = 3000
      target_port = 3000
    }
  }
}
