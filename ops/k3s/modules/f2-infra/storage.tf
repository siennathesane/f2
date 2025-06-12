locals {
  f2-storage-db-namespace = "storage"
}

resource "kubernetes_secret_v1" "f2-storage-db" {
  metadata {
    name      = "f2-storage-db-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "f2storage"
    password = random_password.f2-storage-db-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-storage-db-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "f2-storage-config" {
  metadata {
    name      = "f2-storage-config-${var.environment}"
    namespace = var.namespace
  }

  data = {
    database_url         = "postgres://${kubernetes_secret_v1.f2-storage-db.data.username}:${kubernetes_secret_v1.f2-storage-db.data.password}@${kubectl_manifest.f2-cluster.name}-rw:5432/${local.f2-control-plane-db-name}"
    database_pool_url    = "postgresql://${kubernetes_secret_v1.f2-storage-db.data.username}:${kubernetes_secret_v1.f2-storage-db.data.password}@${kubectl_manifest.f2-cluster.name}-rw:5432/${local.f2-control-plane-db-name}"
    database_search_path = "${local.f2-storage-db-namespace}"
    s3_access_key        = kubernetes_secret_v1.f2-storage-creds.data.username
    s3_secret_key        = kubernetes_secret_v1.f2-storage-creds.data.password
    # todo(siennathesane): figure out what these are?
    s3_protocol_access_key_id     = "625729a08b95bf1b7ff351a663f3a23c"
    s3_protocol_access_key_secret = "850181e4652dd023b7a98c58ae0d2d34bd487ee0cc3254aed6eda37307425907"
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "f2-storage-initdb" {
  metadata {
    name      = "f2-storage-initdb-sql-commands-${var.environment}"
    namespace = var.namespace
  }

  data = {
    "script.sql" = <<-EOT
    GRANT ALL PRIVILEGES ON DATABASE ${local.f2-control-plane-db-name} to ${kubernetes_secret_v1.f2-storage-db.data.username};
    GRANT ALL ON SCHEMA ${local.f2-storage-db-namespace} TO ${kubernetes_secret_v1.f2-storage-db.data.username};
    EOT
  }
}

resource "kubernetes_deployment_v1" "f2-storage-api" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-storage-api-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-storage-api-${var.environment}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-storage-api-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-storage-api-${var.environment}"
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
            name = kubernetes_config_map_v1.f2-storage-initdb.metadata[0].name
          }
        }

        container {
          name  = "f2-storage-api"
          image = "supabase/storage-api:latest"

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
            container_port = 5000
            protocol       = "TCP"
          }

          env {
            name  = "SERVER_PORT"
            value = "5000"
          }

          env {
            name = "AUTH_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name  = "AUTH_JWT_ALGORITHM"
            value = "HS256"
          }

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "database_url"
              }
            }
          }

          env {
            name = "DATABASE_SEARCH_PATH"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "database_search_path"
              }
            }
          }

          env {
            name = "DATABASE_POOL_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "database_pool_url"
              }
            }
          }

          env {
            name  = "DB_INSTALL_ROLES"
            value = "true"
          }

          env {
            name  = "STORAGE_BACKEND"
            value = "s3"
          }

          env {
            name  = "STORAGE_S3_BUCKET"
            value = "f2-control-bucket"
          }

          env {
            name  = "STORAGE_S3_ENDPOINT"
            value = "http://minio.svc.${var.namespace}.cluster.local:9000"
          }

          env {
            name  = "STORAGE_S3_FORCE_PATH_STYLE"
            value = "true"
          }

          env {
            name  = "STORAGE_S3_REGION"
            value = "us-east-1"
          }

          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "s3_access_key"
              }
            }
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "s3_secret_key"
              }
            }
          }

          env {
            name  = "UPLOAD_FILE_SIZE_LIMIT"
            value = "524288000"
          }

          env {
            name  = "UPLOAD_FILE_SIZE_LIMIT_STANDARD"
            value = "52428800"
          }

          env {
            name  = "UPLOAD_SIGNED_URL_EXPIRATION_TIME"
            value = "120"
          }

          env {
            name  = "TUS_URL_PATH"
            value = "/upload/resumable"
          }

          env {
            name  = "TUS_URL_EXPIRY_MS"
            value = "3600000"
          }

          env {
            name  = "IMAGE_TRANSFORMATION_ENABLED"
            value = "true"
          }

          env {
            name  = "IMGPROXY_URL"
            value = "http://${kubernetes_service_v1.f2-imgproxy.metadata[0].name}:80"
          }

          env {
            name  = "IMGPROXY_REQUEST_TIMEOUT"
            value = "15"
          }

          env {
            name = "S3_PROTOCOL_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "s3_protocol_access_key_id"
              }
            }
          }

          env {
            name = "S3_PROTOCOL_ACCESS_KEY_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-storage-config.metadata[0].name
                key  = "s3_protocol_access_key_secret"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/status"
              port = "5000"
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 30
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/status"
              port = "5000"
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

resource "kubernetes_service_v1" "f2-storage-api" {
  metadata {
    name      = "f2-storage-api-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-storage-api-${var.environment}"
    }
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-storage-api-${var.environment}"
    }

    port {
      name        = "http"
      port        = 5000
      target_port = 5000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
