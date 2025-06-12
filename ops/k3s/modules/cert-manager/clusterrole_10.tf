# Generated from Kubernetes ClusterRole: cert-manager-edit
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_edit" {
  metadata {
    name = "cert-manager-edit"

    labels = {
      app                                            = "cert-manager"
      "app.kubernetes.io/component"                  = "controller"
      "app.kubernetes.io/instance"                   = "cert-manager"
      "app.kubernetes.io/managed-by"                 = "Helm"
      "app.kubernetes.io/name"                       = "cert-manager"
      "app.kubernetes.io/version"                    = "v1.18.0"
      "helm.sh/chart"                                = "cert-manager-v1.18.0"
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
    }
  }

  rule {
    verbs      = ["create", "delete", "deletecollection", "patch", "update"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates", "certificaterequests", "issuers"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates/status"]
  }

  rule {
    verbs      = ["create", "delete", "deletecollection", "patch", "update"]
    api_groups = ["acme.cert-manager.io"]
    resources  = ["challenges", "orders"]
  }
}

