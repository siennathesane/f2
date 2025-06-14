resource "kubernetes_manifest" "default_backup_target" {
  manifest = {
    apiVersion = "longhorn.io/v1beta2"
    kind       = "BackupTarget"
    metadata = {
      name      = "default"
      namespace = "longhorn-system"
    }
    spec = {
      backupTargetURL  = "s3://minio.longhorn-system.svc.cluster.local"
      credentialSecret = kubernetes_secret_v1.longhorn-minio-storage-creds.metadata[0].name
      pollInterval     = "5m0s"
    }
  }
}
