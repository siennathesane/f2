resource "kubernetes_secret" "longhorn-minio-config" {
  metadata {
    name      = "longhorn-minio-config"
    namespace = "longhorn-system"
  }

  data = {
    "config.env" = <<-EOT
    export MINIO_ROOT_USER="${kubernetes_secret_v1.longhorn-minio-root-creds.data.username}"
    export MINIO_ROOT_PASSWORD="${kubernetes_secret_v1.longhorn-minio-root-creds.data.password}"
    export MINIO_STORAGE_CLASS_STANDARD="EC:1"
    export MINIO_BROWSER="on"
    EOT
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "longhorn-minio-root-creds" {
  metadata {
    name      = "longhorn-minio-root-creds"
    namespace = "longhorn-system"
  }

  data = {
    username = "minio"
    password = random_password.longhorn-minio-root-password.result
  }

  type = "kubernetes.io/Opaque"
}

resource "random_password" "longhorn-minio-root-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "longhorn-minio-storage-creds" {
  metadata {
    name      = "longhorn-minio-storage-creds"
    namespace = "longhorn-system"
  }

  data = {
    AWS_ACCESS_KEY_ID     = "storage"
    AWS_SECRET_ACCESS_KEY = random_password.longhorn-minio-storage-password.result
    CONSOLE_ACCESS_KEY    = "storage"
    CONSOLE_SECRET_KEY    = random_password.longhorn-minio-storage-password.result
    username              = "storage"
    password              = random_password.longhorn-minio-storage-password.result
  }

  type = "Opaque"
}

resource "random_password" "longhorn-minio-storage-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "longhorn-minio-console-creds" {
  metadata {
    name      = "longhorn-minio-console-creds"
    namespace = "longhorn-system"
  }

  data = {
    CONSOLE_ACCESS_KEY = "console"
    CONSOLE_SECRET_KEY = random_password.longhorn-minio-console-password.result
  }

  type = "Opaque"
}

resource "random_password" "longhorn-minio-console-password" {
  length  = 16
  special = false
}

resource "kubernetes_manifest" "longhorn-minio-tenant" {
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
        "app" = "longhorn-minio"
      }
      name      = "longhorn-minio"
      namespace = "longhorn-system"
    }
    spec = {
      configuration = {
        name = kubernetes_secret.longhorn-minio-config.metadata[0].name
      }
      features = {
        bucketDNS  = true
        enableSFTP = false
      }
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
                  storage = "10Gi"
                }
              }
              storageClassName = "local-path"
            }
          }
          volumesPerServer = 3
        },
      ]
      requestAutoCert = false
      serviceMetadata = {
        minioServiceLabels = {
          "app" = "longhorn-minio"
        }
        consoleServiceLabels = {
          "app" = "longhorn-minio-console"
        }
      }
      users = [
        {
          name = kubernetes_secret_v1.longhorn-minio-console-creds.metadata[0].name
        },
        {
          name = kubernetes_secret_v1.longhorn-minio-storage-creds.metadata[0].name
        },
      ],
    }
  }
}
