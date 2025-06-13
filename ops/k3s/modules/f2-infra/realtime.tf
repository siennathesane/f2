locals {
  f2-realtime-db-namespace = "realtime"
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
    database = local.f2-control-plane-db-name
  }

  type = "Opaque"
}

resource "random_password" "f2-realtime-db-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "f2-realtime-config" {
  metadata {
    name      = "f2-realtime-config-${var.environment}"
    namespace = var.namespace
  }

  data = {
    db_hostname          = "${kubectl_manifest.f2-cluster.name}-rw.${var.environment}.svc.cluster.local"
    db_encryption_key    = "jbZ/1S2hIN7C6iM5"
    postgres_backend_url = "postgres://${kubernetes_secret_v1.f2-realtime-db.data.username}:${kubernetes_secret_v1.f2-realtime-db.data.password}@${kubectl_manifest.f2-cluster.name}-rw:5432/${local.f2-control-plane-db-name}"
    slot_name            = "f2-realtime-${var.environment}"
    api_jwt_secret       = "a68866aa-92fa-4829-b475-31ec8f6e4da5"
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "f2-realtime" {
  metadata {
    name      = "f2-realtime-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-realtime-${var.environment}"
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
        "f2.pub/app" = "f2-realtime-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-realtime-${var.environment}"
        }
      }

      spec {
        container {
          name  = "f2-realtime"
          image = "supabase/realtime:v2.34.47"

          env {
            name  = "APP_NAME"
            value = "realtime"
          }

          env {
            name  = "DB_AFTER_CONNECT_QUERY"
            value = "SET search_path TO ${local.f2-realtime-db-namespace}"
          }

          env {
            name = "DB_HOST"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-config.metadata[0].name
                key  = "db_hostname"
              }
            }
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-db.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-db.metadata[0].name
                key  = "database"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-db.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "DB_ENC_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-config.metadata[0].name
                key  = "db_encryption_key"
              }
            }
          }

          env {
            name = "API_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-config.metadata[0].name
                key  = "api_jwt_secret"
              }
            }
          }

          env {
            name = "SECRET_KEY_BASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name = "SLOT_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-realtime-config.metadata[0].name
                key  = "slot_name"
              }
            }
          }

          env {
            name  = "DB_PORT"
            value = "5432"
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

resource "kubernetes_service_v1" "f2-realtime" {
  metadata {
    name      = "f2-realtime-${var.environment}"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "f2-realtime-${var.environment}"
    }

    port {
      name        = "http"
      port        = 4000
      target_port = 4000
    }
  }
}
