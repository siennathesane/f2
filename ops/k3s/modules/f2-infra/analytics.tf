locals {
  f2-analytics-db-namespace = "_analytics"
}

resource "kubernetes_manifest" "f2-analytics-db" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Database"
    "metadata" = {
      "name"      = "f2-analytics-db"
      "namespace" = var.namespace
    }
    "spec" = {
      "cluster" = {
        "name" =  kubernetes_manifest.f2-cluster.object.metadata.name
      }
      "allowConnections" = true
      "name"             = local.f2-analytics-db-namespace
      "owner"            = kubernetes_secret_v1.f2-analytics-db.data.username
      "schemas" = [{
        "name"  = local.f2-analytics-db-namespace
        "owner" = kubernetes_secret_v1.f2-analytics-db.data.username
      }]
    }
  }
}

resource "kubernetes_secret_v1" "f2-analytics-db" {
  metadata {
    name      = "f2-analytics-db"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "f2analytics"
    password = random_password.f2-analytics-db-password.result
    database = "_analytics"
  }

  type = "Opaque"
}

resource "random_password" "f2-analytics-db-password" {
  length           = 16
  special          = false
}

resource "kubernetes_secret_v1" "f2-analytics-config" {
  metadata {
    name      = "f2-analytics-config"
    namespace = var.namespace
  }

  data = {
    db_database = kubernetes_secret_v1.f2-analytics-db.data.database
    db_hostname = "${kubernetes_manifest.f2-cluster.object.metadata.name}-rw"
    db_password = kubernetes_secret_v1.f2-analytics-db.data.password
    db_encryption_key = "rv9KN3oPYQjiI8U0w1JaeZaCvILZ0l1AEALj24qa9tFdCyQF6VD2lYDIEmoiNd/JBJQlXv4+Up39S0A8qiqTyQ=="
    api_key     = "JvmiXX7ZBep512JW20VFI2+32PxU4QImMP3HOjG+1VM9akNHUhFEuq+6PQcXg3OWn2Y4+gvXqve0f8i/tlikLg=="
    postgres_backend_url = "postgres://${kubernetes_secret_v1.f2-analytics-db.data.username}:${kubernetes_secret_v1.f2-analytics-db.data.password}@${ kubernetes_manifest.f2-cluster.object.metadata.name}-rw:5432/${kubernetes_secret_v1.f2-analytics-db.data.database}"
  }

  type = "Opaque"
}

resource "kubernetes_deployment_v1" "f2-analytics" {
  depends_on = [kubernetes_secret_v1.f2-analytics-db]
  metadata {
    name = "f2-analytics"
    labels = {
      "f2.pub/app" = "f2-analytics-${var.environment}"
    }
    namespace = var.namespace
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
            name  = "LOGFLARE_NODE_HOST"
            value = "0.0.0.0"
          }
          env {
            name = "LOGFLARE_PUBLIC_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = "f2-analytics-config"
                key  = "api_key"
              }
            }
          }
          env {
            name = "POSTGRES_BACKEND_URL"
            value_from {
              secret_key_ref {
                name = "f2-analytics-config"
                key  = "postgres_backend_url"
              }
            }
          }
          env {
            name  = "POSTGRES_BACKEND_SCHEMA"
            value = local.f2-analytics-db-namespace
          }
          env {
            name = "DB_DATABASE"
            value_from {
              secret_key_ref {
                name = "f2-analytics-db"
                key  = "database"
              }
            }
          }
          env {
            name = "DB_HOSTNAME"
            value_from {
              secret_key_ref {
                name = "f2-analytics-config"
                key  = "db_hostname"
              }
            }
          }
          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = "f2-analytics-db"
                key  = "username"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "f2-analytics-db"
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
