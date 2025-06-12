# Generated from Kubernetes ClusterRoleBinding: cert-manager-webhook:subjectaccessreviews
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role_binding" "cert_manager_webhook_subjectaccessreviews" {
  metadata {
    name = "cert-manager-webhook:subjectaccessreviews"

    labels = {
      app                            = "webhook"
      "app.kubernetes.io/component"  = "webhook"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "webhook"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager-webhook"
    namespace = "cert-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cert-manager-webhook:subjectaccessreviews"
  }
}

