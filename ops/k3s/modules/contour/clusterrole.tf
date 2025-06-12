# Generated from Kubernetes ClusterRole: contour
# API Version: rbac.authorization.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_cluster_role" "contour" {
  metadata {
    name = "contour"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "namespaces", "secrets", "services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["gateway.networking.k8s.io"]
    resources  = ["backendtlspolicies", "gatewayclasses", "gateways", "grpcroutes", "httproutes", "referencegrants", "tcproutes", "tlsroutes"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["gateway.networking.k8s.io"]
    resources  = ["backendtlspolicies/status", "gatewayclasses/status", "gateways/status", "grpcroutes/status", "httproutes/status", "tcproutes/status", "tlsroutes/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["create", "get", "update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["projectcontour.io"]
    resources  = ["contourconfigurations", "extensionservices", "httpproxies", "tlscertificatedelegations"]
  }

  rule {
    verbs      = ["create", "get", "update"]
    api_groups = ["projectcontour.io"]
    resources  = ["contourconfigurations/status", "extensionservices/status", "httpproxies/status"]
  }
}

