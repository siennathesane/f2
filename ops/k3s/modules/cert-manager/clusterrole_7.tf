# Generated from Kubernetes ClusterRole: cert-manager-controller-ingress-shim
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_controller_ingress_shim" {
  metadata {
    name = "cert-manager-controller-ingress-shim"

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
    verbs      = ["create", "update", "delete"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates", "certificaterequests"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cert-manager.io"]
    resources  = ["certificates", "certificaterequests", "issuers", "clusterissuers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/finalizers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["gateway.networking.k8s.io"]
    resources  = ["gateways", "httproutes"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["gateway.networking.k8s.io"]
    resources  = ["gateways/finalizers", "httproutes/finalizers"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

