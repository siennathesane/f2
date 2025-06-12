# Generated from Kubernetes ClusterRole: cert-manager-cluster-view
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_cluster_view" {
  metadata {
    name = "cert-manager-cluster-view"

    labels = {
      app                                                     = "cert-manager"
      "app.kubernetes.io/component"                           = "controller"
      "app.kubernetes.io/instance"                            = "cert-manager"
      "app.kubernetes.io/managed-by"                          = "Helm"
      "app.kubernetes.io/name"                                = "cert-manager"
      "app.kubernetes.io/version"                             = "v1.18.0"
      "helm.sh/chart"                                         = "cert-manager-v1.18.0"
      "rbac.authorization.k8s.io/aggregate-to-cluster-reader" = "true"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["clusterissuers"]
  }
}

