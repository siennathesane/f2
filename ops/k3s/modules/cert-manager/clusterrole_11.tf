# Generated from Kubernetes ClusterRole: cert-manager-controller-approve:cert-manager-io
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_controller_approve_cert_manager_io" {
  metadata {
    name = "cert-manager-controller-approve:cert-manager-io"

    labels = {
      app                            = "cert-manager"
      "app.kubernetes.io/component"  = "cert-manager"
      "app.kubernetes.io/instance"   = "cert-manager"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cert-manager"
      "app.kubernetes.io/version"    = "v1.18.0"
      "helm.sh/chart"                = "cert-manager-v1.18.0"
    }
  }

  rule {
    verbs          = ["approve"]
    api_groups     = ["cert-manager.io"]
    resources      = ["signers"]
    resource_names = ["issuers.cert-manager.io/*", "clusterissuers.cert-manager.io/*"]
  }
}

