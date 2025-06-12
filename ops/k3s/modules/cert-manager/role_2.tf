# Generated from Kubernetes Role: cert-manager-tokenrequest
# Namespace: cert-manager
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_role" "cert_manager_tokenrequest" {
  metadata {
    name      = "cert-manager-tokenrequest"
    namespace = "cert-manager"

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
    verbs          = ["create"]
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    resource_names = ["cert-manager"]
  }
}

