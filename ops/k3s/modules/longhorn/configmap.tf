# Generated from Kubernetes ConfigMap: longhorn-default-resource
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_config_map" "longhorn_default_resource" {
  metadata {
    name      = "longhorn-default-resource"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }
}

