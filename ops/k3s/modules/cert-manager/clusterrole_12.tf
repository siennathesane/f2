# Generated from Kubernetes ClusterRole: cert-manager-controller-certificatesigningrequests
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "cert_manager_controller_certificatesigningrequests" {
  metadata {
    name = "cert-manager-controller-certificatesigningrequests"

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
    verbs      = ["get", "list", "watch", "update"]
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
  }

  rule {
    verbs      = ["update", "patch"]
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests/status"]
  }

  rule {
    verbs          = ["sign"]
    api_groups     = ["certificates.k8s.io"]
    resources      = ["signers"]
    resource_names = ["issuers.cert-manager.io/*", "clusterissuers.cert-manager.io/*"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
  }
}

