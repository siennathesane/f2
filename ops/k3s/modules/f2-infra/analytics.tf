locals {
  f2-analytics-db-namespace = "analytics"
}

resource "kubernetes_secret_v1" "f2-analytics-db" {
  metadata {
    name      = "f2-analytics-db-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "f2analytics"
    password = random_password.f2-analytics-db-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-analytics-db-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "f2-analytics-config" {
  metadata {
    name      = "f2-analytics-config-${var.environment}"
    namespace = var.namespace
  }

  data = {
    db_database          = local.f2-control-plane-db-name
    db_hostname          = "${kubectl_manifest.f2-cluster.name}-rw.${var.namespace}.svc.cluster.local"
    db_password          = kubernetes_secret_v1.f2-analytics-db.data.password
    db_encryption_key    = "rv9KN3oPYQjiI8U0w1JaeZaCvILZ0l1AEALj24qa9tFdCyQF6VD2lYDIEmoiNd/JBJQlXv4+Up39S0A8qiqTyQ=="
    api_key              = "38040e21-9a55-4f1e-a381-fd6896e3265b"
    private_api_key      = "baf0b1df-ed34-4e9c-9696-90fe280117b3"
    postgres_backend_url = "postgres://${kubernetes_secret_v1.f2-analytics-db.data.username}:${kubernetes_secret_v1.f2-analytics-db.data.password}@${kubectl_manifest.f2-cluster.name}-rw.${var.namespace}.svc.cluster.local:5432/${local.f2-control-plane-db-name}"
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "f2-analytics-initdb" {
  metadata {
    name      = "f2-analytics-initdb-sql-commands-${var.environment}"
    namespace = var.namespace
  }

  data = {
    "script.sql" = <<-EOT
    --- ALTER USER ${kubernetes_secret_v1.f2-auth-config.data.username} WITH LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
    --- GRANT ${kubernetes_secret_v1.f2-auth-config.data.username} TO postgres;
    --- CREATE SCHEMA IF NOT EXISTS ${local.f2-auth-db-namespace} AUTHORIZATION ${kubernetes_secret_v1.f2-auth-config.data.username};
    --- GRANT CREATE ON DATABASE postgres TO ${kubernetes_secret_v1.f2-auth-config.data.username};
    --- ALTER USER ${kubernetes_secret_v1.f2-auth-config.data.username} SET search_path = '${local.f2-auth-db-namespace}';
    EOT
  }
}

resource "kubernetes_deployment_v1" "f2-analytics" {
  depends_on = [kubernetes_secret_v1.f2-analytics-db]
  metadata {
    name = "f2-analytics-${var.environment}"
    labels = {
      "f2.pub/app" = "f2-analytics-${var.environment}"
    }
    namespace = var.namespace
  }

  timeouts {
    create = "2m"
    update = "2m"
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
          image = "supabase/logflare:1.14.2"
          name  = "f2-analytics-${var.environment}"

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          port {
            name           = "http"
            container_port = 4000
            protocol       = "TCP"
          }

          env {
            name  = "LOGFLARE_SINGLE_TENANT"
            value = "true"
          }

          env {
            name  = "LOGFLARE_SUPABASE_MODE"
            value = "true"
          }

          env {
            name = "LOGFLARE_NODE_HOST"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name  = "LOGFLARE_NODE_PORT"
            value = "4000"
          }

          env {
            name  = "PHX_URL_HOST"
            value = "0.0.0.0"
          }

          env {
            name  = "PHX_HTTP_PORT"
            value = "4000"
          }

          env {
            name = "LOGFLARE_PUBLIC_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-analytics-config.metadata[0].name
                key  = "api_key"
              }
            }
          }
          env {
            name = "LOGFLARE_PRIVATE_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-analytics-config.metadata[0].name
                key  = "private_api_key"
              }
            }
          }
          env {
            name = "POSTGRES_BACKEND_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-analytics-config.metadata[0].name
                key  = "postgres_backend_url"
              }
            }
          }
          env {
            name  = "POSTGRES_BACKEND_SCHEMA"
            value = local.f2-analytics-db-namespace
          }
          env {
            name  = "DB_DATABASE"
            value = local.f2-control-plane-db-name
          }
          env {
            name = "DB_HOSTNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-analytics-config.metadata[0].name
                key  = "db_hostname"
              }
            }
          }
          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-analytics-db.metadata[0].name
                key  = "username"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-analytics-db.metadata[0].name
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-analytics" {
  metadata {
    name      = "f2-analytics-${var.environment}"
    namespace = var.namespace
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-analytics-${var.environment}"
    }

    port {
      name        = "http"
      port        = 4000
      target_port = 4000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
