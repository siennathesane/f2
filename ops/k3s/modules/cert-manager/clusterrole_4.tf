# Generated from Kubernetes ClusterRole: cert-manager-controller-orders
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_controller_orders" {
  metadata {
    name = "cert-manager-controller-orders"

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
    api_groups = ["acme.cert-manager.io"]
    resources  = ["orders", "orders/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["acme.cert-manager.io"]
    resources  = ["orders", "challenges"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["clusterissuers", "issuers"]
  }

  rule {
    verbs      = ["create", "delete"]
    api_groups = ["acme.cert-manager.io"]
    resources  = ["challenges"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["acme.cert-manager.io"]
    resources  = ["orders/finalizers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

