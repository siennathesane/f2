# Generated from Kubernetes ClusterRole: cnpg-cloudnative-pg
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cnpg_cloudnative_pg" {
  metadata {
    name = "cnpg-cloudnative-pg"

    labels = {
      "app.kubernetes.io/instance"   = "cnpg"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudnative-pg"
      "app.kubernetes.io/version"    = "1.26.0"
      "helm.sh/chart"                = "cloudnative-pg-0.24.0"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "patch"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["clusterimagecatalogs"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "secrets", "services"]
  }

  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = [""]
    resources  = ["configmaps/status", "secrets/status"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims", "pods", "pods/exec"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["pods/status"]
  }

  rule {
    verbs      = ["create", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["serviceaccounts"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["deployments"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "watch"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["create", "get", "update"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "watch"]
    api_groups = ["monitoring.coreos.com"]
    resources  = ["podmonitors"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["backups", "clusters", "databases", "poolers", "publications", "scheduledbackups", "subscriptions"]
  }

  rule {
    verbs      = ["get", "patch", "update"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["backups/status", "databases/status", "publications/status", "scheduledbackups/status", "subscriptions/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["imagecatalogs"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["clusters/finalizers", "poolers/finalizers"]
  }

  rule {
    verbs      = ["get", "patch", "update", "watch"]
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["clusters/status", "poolers/status"]
  }

  rule {
    verbs      = ["create", "get", "list", "patch", "update", "watch"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["rolebindings", "roles"]
  }

  rule {
    verbs      = ["create", "get", "list", "patch", "watch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
  }
}

