# Generated from Kubernetes PriorityClass: longhorn-critical
# API Version: scheduling.k8s.io/v1
# Type: Standard Resource

resource "kubernetes_priority_class" "longhorn_critical" {
  metadata {
    name = "longhorn-critical"

    labels = {
      "app.kubernetes.io/instance" = "longhorn"
      "app.kubernetes.io/name"     = "longhorn"
      "app.kubernetes.io/version"  = "v1.9.0"
    }
  }

  value             = 1000000000
  description       = "Ensure Longhorn pods have the highest priority to prevent any unexpected eviction by the Kubernetes scheduler under node pressure"
  preemption_policy = "PreemptLowerPriority"
}

