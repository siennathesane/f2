# Generated from Kubernetes ConfigMap: longhorn-default-setting
# Namespace: longhorn-system
# API Version: v1
# Type: Standard Resource

resource "kubernetes_config_map" "longhorn_default_setting" {
  metadata {
    name      = "longhorn-default-setting"
    namespace = "longhorn-system"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  data = {
    "default-setting.yaml" = "priority-class: longhorn-critical\ndisable-revision-counter: true"
  }
}

