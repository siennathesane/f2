# Generated from Kubernetes ClusterRole: cert-manager-view
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_view" {
  metadata {
    name = "cert-manager-view"

    labels = {
      app                                                     = "cert-manager"
      "app.kubernetes.io/component"                           = "controller"
      "app.kubernetes.io/instance"                            = "cert-manager"
      "app.kubernetes.io/managed-by"                          = "Helm"
      "app.kubernetes.io/name"                                = "cert-manager"
      "app.kubernetes.io/version"                             = "v1.18.0"
      "helm.sh/chart"                                         = "cert-manager-v1.18.0"
      "rbac.authorization.k8s.io/aggregate-to-admin"          = "true"
      "rbac.authorization.k8s.io/aggregate-to-cluster-reader" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"           = "true"
      "rbac.authorization.k8s.io/aggregate-to-view"           = "true"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates", "certificaterequests", "issuers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["acme.cert-manager.io"]
    resources  = ["challenges", "orders"]
  }
}

