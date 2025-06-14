# Generated from Kubernetes ConfigMap: longhorn-storageclass
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_config_map" "longhorn_storageclass" {
  metadata {
    name      = "longhorn-storageclass"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  data = {
    "storageclass.yaml" = "kind: StorageClass\napiVersion: storage.k8s.io/v1\nmetadata:\n  name: longhorn\n  annotations:\n    storageclass.kubernetes.io/is-default-class: \"true\"\nprovisioner: driver.longhorn.io\nallowVolumeExpansion: true\nreclaimPolicy: \"Delete\"\nvolumeBindingMode: Immediate\nparameters:\n  numberOfReplicas: \"3\"\n  staleReplicaTimeout: \"30\"\n  fromBackup: \"\"\n  fsType: \"ext4\"\n  dataLocality: \"disabled\"\n  unmapMarkSnapChainRemoved: \"ignored\"\n  disableRevisionCounter: \"true\"\n  dataEngine: \"v1\"\n  backupTargetName: \"default\"\n"
  }
}

