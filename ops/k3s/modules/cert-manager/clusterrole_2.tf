# Generated from Kubernetes ClusterRole: cert-manager-controller-clusterissuers
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_controller_clusterissuers" {
  metadata {
    name = "cert-manager-controller-clusterissuers"

    labels = {
      app                            = "cert-manager"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cert-manager"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  rule {
    verbs      = ["update", "patch"]
    api_groups = ["cert-manager.io"]
    resources  = ["clusterissuers", "clusterissuers/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["clusterissuers"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

