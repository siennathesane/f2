# Generated from Kubernetes ClusterRole: cert-manager-controller-certificates
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_controller_certificates" {
  metadata {
    name = "cert-manager-controller-certificates"

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
    resources  = ["certificates", "certificates/status", "certificaterequests", "certificaterequests/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates", "certificaterequests", "clusterissuers", "issuers"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates/finalizers", "certificaterequests/finalizers"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "watch"]
    api_groups = ["acme.cert-manager.io"]
    resources  = ["orders"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

