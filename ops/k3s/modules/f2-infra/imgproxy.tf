resource "kubernetes_deployment_v1" "f2-imgproxy" {

  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-imgproxy-${var.environment}"
    namespace = var.namespace

    labels = {
      "f2.pub/app" = "f2-imgproxy-${var.environment}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-imgproxy-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-imgproxy-${var.environment}"
        }
      }

      spec {
        container {
          name  = "f2-imgproxy"
          image = "ghcr.io/imgproxy/imgproxy:v3.28.0"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "metrics"
            container_port = 8081
            protocol       = "TCP"
          }

          env {
            name  = "IMGPROXY_LOCAL_FILESYSTEM_ROOT"
            value = "/tmp"
          }

          env {
            name  = "IMGPROXY_USE_ETAG"
            value = true
          }

          env {
            name  = "IMGPROXY_ENABLE_WEBP_DETECTION"
            value = true
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = "8080"
              scheme = "HTTP"
            }

            initial_delay_seconds = 50
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path   = "/health"
              port   = "8080"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 5
          }

          image_pull_policy = "IfNotPresent"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "25%"
        max_surge       = "25%"
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-imgproxy" {
  metadata {
    name      = "f2-imgproxy-${var.environment}"
    namespace = var.namespace

    labels = {
      "f2.pub/app" = "f2-imgproxy-${var.environment}"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 8081
      target_port = "8081"
    }

    selector = {
      "f2.pub/app" = "f2-imgproxy-${var.environment}"
    }

    type = "ClusterIP"
  }
}
