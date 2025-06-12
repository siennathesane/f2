# Generated from Kubernetes ClusterRole: minio-operator-role
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "minio_operator_role" {
  metadata {
    name = "minio-operator-role"
  }

  rule {
    verbs      = ["get", "update"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["get", "update", "list"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["create", "get", "watch", "list"]
    api_groups = [""]
    resources  = ["namespaces", "nodes"]
  }

  rule {
    verbs      = ["get", "watch", "create", "list", "delete", "deletecollection", "update", "patch"]
    api_groups = [""]
    resources  = ["pods", "services", "events", "configmaps"]
  }

  rule {
    verbs      = ["get", "watch", "create", "update", "list", "delete", "deletecollection"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["serviceaccounts"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
  }

  rule {
    verbs      = ["get", "create", "list", "patch", "watch", "update", "delete"]
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments", "deployments/finalizers"]
  }

  rule {
    verbs      = ["get", "create", "list", "patch", "watch", "update", "delete"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["update", "create", "get", "delete", "list"]
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests", "certificatesigningrequests/approval", "certificatesigningrequests/status"]
  }

  rule {
    verbs          = ["approve", "sign"]
    api_groups     = ["certificates.k8s.io"]
    resources      = ["signers"]
    resource_names = ["kubernetes.io/legacy-unknown", "kubernetes.io/kube-apiserver-client", "kubernetes.io/kubelet-serving", "beta.eks.amazonaws.com/app-serving"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["minio.min.io", "sts.min.io", "job.min.io"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["min.io"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["get", "update", "list"]
    api_groups = ["monitoring.coreos.com"]
    resources  = ["prometheuses", "prometheusagents"]
  }

  rule {
    verbs      = ["get", "update", "create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "deletecollection"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }
}
