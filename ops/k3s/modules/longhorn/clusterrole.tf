# Generated from Kubernetes ClusterRole: longhorn-role
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "longhorn_role" {
  metadata {
    name = "longhorn-role"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  rule {
    verbs      = ["*"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["pods", "events", "persistentvolumes", "persistentvolumeclaims", "persistentvolumeclaims/status", "nodes", "proxy/nodes", "pods/log", "secrets", "services", "endpoints", "configmaps", "serviceaccounts"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["apps"]
    resources  = ["daemonsets", "statefulsets", "deployments"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets", "podsecuritypolicies"]
  }

  rule {
    verbs      = ["watch", "list"]
    api_groups = ["scheduling.k8s.io"]
    resources  = ["priorityclasses"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "volumeattachments", "volumeattachments/status", "csinodes", "csidrivers"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses", "volumesnapshots", "volumesnapshotcontents", "volumesnapshotcontents/status"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["longhorn.io"]
    resources  = ["volumes", "volumes/status", "engines", "engines/status", "replicas", "replicas/status", "settings", "settings/status", "engineimages", "engineimages/status", "nodes", "nodes/status", "instancemanagers", "instancemanagers/status", "sharemanagers", "sharemanagers/status", "backingimages", "backingimages/status", "backingimagemanagers", "backingimagemanagers/status", "backingimagedatasources", "backingimagedatasources/status", "backuptargets", "backuptargets/status", "backupvolumes", "backupvolumes/status", "backups", "backups/status", "recurringjobs", "recurringjobs/status", "orphans", "orphans/status", "snapshots", "snapshots/status", "supportbundles", "supportbundles/status", "systembackups", "systembackups/status", "systemrestores", "systemrestores/status", "volumeattachments", "volumeattachments/status", "backupbackingimages", "backupbackingimages/status"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apiregistration.k8s.io"]
    resources  = ["apiservices"]
  }

  rule {
    verbs      = ["get", "list", "create", "patch", "delete"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterrolebindings", "clusterroles"]
  }
}

