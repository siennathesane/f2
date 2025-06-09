locals {
  f2-realtime-db-namespace = "_realtime"
}

resource "kubernetes_manifest" "f2-realtime-db" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Database"
    "metadata" = {
      "name"      = "f2-realtime-db"
      "namespace" = var.namespace
    }
    "spec" = {
      "cluster" = {
        "name" =  kubernetes_manifest.f2-cluster.object.metadata.name
      }
      "allowConnections" = true
      "name"             = local.f2-realtime-db-namespace
      "owner"            = kubernetes_secret_v1.f2-realtime-db.data.username
      "schemas" = [{
        "name"  = local.f2-realtime-db-namespace
        "owner" = kubernetes_secret_v1.f2-realtime-db.data.username
      }]
    }
  }
}

resource "kubernetes_secret_v1" "f2-realtime-db" {
  metadata {
    name      = "f2-realtime-db"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "f2realtime"
    password = random_password.f2-realtime-db-password.result
    database = "_realtime"
  }

  type = "Opaque"
}

resource "random_password" "f2-realtime-db-password" {
  length           = 16
  special          = false
}

resource "kubernetes_secret_v1" "f2-realtime-config" {
  metadata {
    name      = "f2-realtime-config"
    namespace = var.namespace
  }

  data = {
    db_hostname = "${kubernetes_manifest.f2-cluster.object.metadata.name}-rw"
    db_encryption_key = "jbZ/1S2hIN7C6iM512kPNaVq3KMERDOsR1r6y3ThGF2uxjrnOQ7NIJQFVNObRhHzE0iZpoVuPQ5Vz0lkMSvIXg=="
    postgres_backend_url = "postgres://${kubernetes_secret_v1.f2-realtime-db.data.username}:${kubernetes_secret_v1.f2-realtime-db.data.password}@${kubernetes_manifest.f2-cluster.object.metadata.name}-rw:5432/${kubernetes_secret_v1.f2-realtime-db.data.database}"
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "f2-realtime" {
  metadata {
    name = "f2-realtime"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-realtime-${var.environment}"
    }
  }

  timeouts {
    create = "2m"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-analytics-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-analytics-${var.environment}"
        }
      }

      spec {
        container {
          name  = "f2-realtime"
          image = "supabase/realtime:v2.34.47"

          env {
            name = "API_JWT_SECRET"
          }

          env {
            name  = "APP_NAME"
            value = "realtime"
          }

          env {
            name  = "DB_AFTER_CONNECT_QUERY"
            value = "SET search_path TO _realtime"
          }

          env {
            name  = "DB_ENC_KEY"
            value = "supabaserealtime"
          }

          env {
            name = "DB_HOSTNAME"
            value_from {
              secret_key_ref {
                name = "f2-realtime-config"
                key  = "db_hostname"
              }
            }
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = "f2-realtime-db"
                key  = "username"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "f2-realtime-db"
                key  = "password"
              }
            }
          }

          env {
            name = "DB_PORT"
          }

          env {
            name  = "DB_USER"
            value = "supabase_admin"
          }

          env {
            name  = "DNS_NODES"
            value = "''"
          }

          env {
            name  = "ERL_AFLAGS"
            value = "-proto_dist inet_tcp"
          }

          env {
            name  = "PORT"
            value = "4000"
          }

          env {
            name  = "RLIMIT_NOFILE"
            value = "10000"
          }

          env {
            name  = "RUN_JANITOR"
            value = "true"
          }

          env {
            name = "SECRET_KEY_BASE"
          }

          env {
            name  = "SEED_SELF_HOST"
            value = "true"
          }

          liveness_probe {
            exec {
              command = ["curl", "-sSfL", "--head", "-o", "/dev/null", "-H", "Authorization: Bearer ", "http://localhost:4000/api/tenants/realtime-dev/health"]
            }

            timeout_seconds   = 5
            period_seconds    = 5
            failure_threshold = 3
          }
        }

        restart_policy = "Always"
      }
    }
  }
}
