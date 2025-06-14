resource "kubernetes_secret" "f2-minio-config" {
  metadata {
    name      = "f2-minio-config-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    "config.env" = <<-EOT
    export MINIO_ROOT_USER="${kubernetes_secret_v1.f2-minio-root-creds.data.username}"
    export MINIO_ROOT_PASSWORD="${kubernetes_secret_v1.f2-minio-root-creds.data.password}"
    export MINIO_STORAGE_CLASS_STANDARD="EC:1"
    export MINIO_BROWSER="on"
    EOT
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "f2-minio-root-creds" {
  metadata {
    name      = "f2-minio-root-creds-${var.environment}"
    namespace = var.namespace
  }

  data = {
    username = "minio"
    password = random_password.f2-minio-root-password.result
  }

  type = "kubernetes.io/Opaque"
}

resource "random_password" "f2-minio-root-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "f2-storage-creds" {
  metadata {
    name      = "f2-minio-storage-creds-${var.environment}"
    namespace = var.namespace
  }

  data = {
    username           = "storage"
    password           = random_password.f2-storage-password.result
    CONSOLE_ACCESS_KEY = "storage"
    CONSOLE_SECRET_KEY = random_password.f2-storage-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-storage-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "f2-minio-console-creds" {
  metadata {
    name      = "f2-minio-console-creds-${var.environment}"
    namespace = var.namespace
  }

  data = {
    CONSOLE_ACCESS_KEY = "console"
    CONSOLE_SECRET_KEY = random_password.f2-minio-console-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-minio-console-password" {
  length  = 16
  special = false
}

resource "kubernetes_manifest" "f2-minio-tenant" {
  manifest = {
    apiVersion = "minio.min.io/v2"
    kind       = "Tenant"
    metadata = {
      annotations = {
        "prometheus.io/path"   = "/minio/v2/metrics/cluster"
        "prometheus.io/port"   = "9000"
        "prometheus.io/scrape" = "true"
      }
      labels = {
        "f2.pub/app" = "f2-minio-${var.namespace}"
      }
      name      = "f2-minio-${var.namespace}"
      namespace = var.namespace
    }
    spec = {
      configuration = {
        name = "f2-minio-config-${var.namespace}"
      }
      features = {
        bucketDNS  = true
        enableSFTP = false
      }
      buckets = [{
        name = "f2-control-plane"
      }]
      image     = "quay.io/minio/minio:latest"
      mountPath = "/export"
      pools = [
        {
          containerSecurityContext = {
            allowPrivilegeEscalation = false
            capabilities = {
              drop = [
                "ALL",
              ]
            }
            runAsGroup   = 1000
            runAsNonRoot = true
            runAsUser    = 1000
            seccompProfile = {
              type = "RuntimeDefault"
            }
          }
          name = "pool-0"
          securityContext = {
            fsGroup             = 1000
            fsGroupChangePolicy = "OnRootMismatch"
            runAsGroup          = 1000
            runAsNonRoot        = true
            runAsUser           = 1000
          }
          servers = 1
          volumeClaimTemplate = {
            apiVersion = "v1"
            kind       = "persistentvolumeclaims"
            spec = {
              accessModes = [
                "ReadWriteOnce",
              ]
              resources = {
                requests = {
                  storage = "3Gi"
                }
              }
            }
          }
          volumesPerServer = 3
        },
      ]
      requestAutoCert = false
      serviceMetadata = {
        minioServiceLabels = {
          "f2.pub/app" = "f2-minio-${var.namespace}"
        }
        consoleServiceLabels = {
          "f2.pub/app" = "f2-minio-console-${var.namespace}"
        }
      }
      users = [
        {
          name = kubernetes_secret_v1.f2-minio-console-creds.metadata[0].name
        },
        {
          name = kubernetes_secret_v1.f2-storage-creds.metadata[0].name
        },
      ],
    }
  }
}
