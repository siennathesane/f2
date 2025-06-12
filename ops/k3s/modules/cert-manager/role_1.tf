# Generated from Kubernetes Role: cert-manager:leaderelection
# Namespace: kube-system
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role" "cert_manager_leaderelection" {
  metadata {
    name      = "cert-manager:leaderelection"
    namespace = "kube-system"

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
    verbs          = ["get", "update", "patch"]
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["cert-manager-controller"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

