resource "kubernetes_secret_v1" "f2-vector-config" {
  metadata {
    name      = "f2-vector-config-${var.environment}"
    namespace = var.namespace
  }

  data = {
    logflare_public_access_token = kubernetes_secret_v1.f2-analytics-config.data.api_key
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "f2-vector-config" {
  metadata {
    name      = "f2-vector-config-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }
  }

  data = {
    "vector.yml" = <<-EOT
    api:
      enabled: true
      address: 0.0.0.0:9001

    sources:
      kubernetes_host:
        type: kubernetes_logs

    transforms:
      project_logs:
        type: remap
        inputs:
          - kubernetes_host
        source: |-
          .project = "f2-${var.environment}"
          .event_message = del(.message)
          .appname = del(.kubernetes.container_name)
          del(.kubernetes.container_id)
          del(.kubernetes.pod_name)
          del(.kubernetes.pod_namespace)
          del(.kubernetes.pod_uid)
          del(.source_type)
          del(.stream)
          del(.host)
      router:
        type: route
        inputs:
          - project_logs
        route:
          # kong: 'contains!(.appname, "f2-kong")'
          auth: 'contains!(.appname, "f2-auth")'
          rest: 'contains!(.appname, "f2-postgrest")'
          realtime: 'contains!(.appname, "f2-realtime")'
          storage: 'contains!(.appname, "f2-storage")'
          functions: 'contains!(.appname, "f2-functions")'
          db: 'contains!(.appname, "f2-postgres") || contains!(.appname, "postgres")'
      # Gotrue logs are structured json strings which frontend parses directly. But we keep metadata for consistency.
      auth_logs:
        type: remap
        inputs:
          - router.auth
        source: |-
          parsed, err = parse_json(.event_message)
          if err == null {
              .metadata.timestamp = parsed.time
              .metadata = merge!(.metadata, parsed)
          }
      # PostgREST logs are structured so we separate timestamp from message using regex
      rest_logs:
        type: remap
        inputs:
          - router.rest
        source: |-
          parsed, err = parse_regex(.event_message, r'^(?P<time>.*): (?P<msg>.*)$')
          if err == null {
            .event_message = parsed.msg
            .timestamp = parse_timestamp!(parsed.time, format: "%d/%b/%Y:%H:%M:%S %z") ||
                         parsed.time
            .metadata.host = .project
          }
      realtime_logs:
        type: remap
        inputs:
          - router.realtime
        source: |-
          .metadata.project = del(.project)
          .metadata.external_id = .metadata.project
          parsed, err = parse_regex(.event_message, r'^(?P<time>\d+:\d+:\d+\.\d+) \[(?P<level>\w+)\] (?P<msg>.*)$')
          if err == null {
            .event_message = parsed.msg
            .metadata.level = parsed.level
          }
      # Storage logs may contain json objects so we parse them for completeness
      storage_logs:
        type: remap
        inputs:
          - router.storage
        source: |-
          .metadata.project = del(.project)
          .metadata.tenantId = .metadata.project
          parsed, err = parse_json(.event_message)
          if err == null {
            .event_message = parsed.msg
            .metadata.level = parsed.level
            .metadata.timestamp = parsed.time
            .metadata.context[0].host = parsed.hostname
            .metadata.context[0].pid = parsed.pid
          }
      db_logs:
        type: remap
        inputs:
          - router.db
        source: |-
          .metadata.host = "db-default"
          .metadata.parsed.timestamp = .timestamp

          parsed, err = parse_regex(.event_message, r'.*(?P<level>INFO|NOTICE|WARNING|ERROR|LOG|FATAL|PANIC?):.*', numeric_groups: true)

          if err != null || parsed == null {
            .metadata.parsed.error_severity = "info"
          }
          if parsed != null {
            .metadata.parsed.error_severity = parsed.level
          }
          if .metadata.parsed.error_severity == "info" {
              .metadata.parsed.error_severity = "log"
          }
          .metadata.parsed.error_severity = upcase!(.metadata.parsed.error_severity)
    sinks:
      logflare_auth:
        type: 'http'
        inputs:
          - auth_logs
        encoding:
          codec: 'json'
        method: 'post'
        request:
          retry_max_duration_secs: 10
          headers:
            x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
        uri: 'http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.svc.${var.environment}.cluster.local:4000/api/logs?source_name=gotrue.logs.${var.environment}'
      logflare_realtime:
        type: 'http'
        inputs:
          - realtime_logs
        encoding:
          codec: 'json'
        method: 'post'
        request:
          retry_max_duration_secs: 10
          headers:
            x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
        uri: 'http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.svc.${var.environment}.cluster.local:4000/api/logs?source_name=realtime.logs.${var.environment}'
      logflare_rest:
        type: 'http'
        inputs:
          - rest_logs
        encoding:
          codec: 'json'
        method: 'post'
        request:
          retry_max_duration_secs: 10
          headers:
            x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
        uri: 'http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.svc.${var.environment}.cluster.local:4000/api/logs?source_name=postgREST.logs.${var.environment}'
      # logflare_db:
      #   type: 'http'
      #   inputs:
      #     - db_logs
      #   encoding:
      #     codec: 'json'
      #   method: 'post'
      #   request:
      #     retry_max_duration_secs: 10
      #     headers:
      #       x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
      #   # We must route the sink through kong because ingesting logs before logflare is fully initialised will
      #   # lead to broken queries from studio. This works by the assumption that containers are started in the
      #   # following order: vector > db > logflare > kong
      #   # todo(siennathesane): update this after the routing is fixed
      #   uri: 'http://kong:8000/analytics/v1/api/logs?source_name=postgres.logs'
      logflare_functions:
        type: 'http'
        inputs:
          - router.functions
        encoding:
          codec: 'json'
        method: 'post'
        request:
          retry_max_duration_secs: 10
          headers:
            x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
        uri: 'http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.svc.${var.environment}.cluster.local:4000/api/logs?source_name=deno-relay-logs'
      logflare_storage:
        type: 'http'
        inputs:
          - storage_logs
        encoding:
          codec: 'json'
        method: 'post'
        request:
          retry_max_duration_secs: 10
          headers:
            x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
        uri: 'http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.svc.${var.environment}.cluster.local:4000/api/logs?source_name=storage.logs.${var.environment}.2'
      # logflare_kong:
      #   type: 'http'
      #   inputs:
      #     - kong_logs
      #     - kong_err
      #   encoding:
      #     codec: 'json'
      #   method: 'post'
      #   request:
      #     retry_max_duration_secs: 10
      #     headers:
      #       x-api-key: ${kubernetes_secret_v1.f2-analytics-config.data.api_key}
      #   uri: 'http://${kubernetes_service_v1.f2-analytics.metadata[0].name}.svc.${var.environment}.cluster.local:4000/api/logs?source_name=cloudflare.logs.${var.environment}.2'
EOT
  }
}

resource "kubernetes_service_account" "f2-vector" {
  metadata {
    name      = "f2-vector-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }
  }
}

resource "kubernetes_cluster_role" "f2-vector" {
  metadata {
    name = "f2-vector-${var.environment}"
    labels = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "f2-vector" {
  metadata {
    name = "f2-vector-${var.environment}"
    labels = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.f2-vector.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.f2-vector.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_daemon_set_v1" "f2-vector" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-vector-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }
  }

  spec {
    selector {
      match_labels = {
        "f2.pub/app" = "f2-vector-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-vector-${var.environment}"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.f2-vector.metadata[0].name

        container {
          name  = "f2-vector"
          image = "timberio/vector:0.47.0-alpine"

          args = [
            "--config",
            "/etc/vector/vector.yml",
            "--watch-config"
          ]

          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          port {
            name           = "api"
            container_port = 9001
            protocol       = "TCP"
          }

          env {
            name = "LOGFLARE_PUBLIC_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-vector-config.metadata[0].name
                key  = "logflare_public_access_token"
              }
            }
          }

          env {
            name = "VECTOR_SELF_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "VECTOR_SELF_POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "VECTOR_SELF_POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/vector"
            read_only  = true
          }

          volume_mount {
            name       = "var-log"
            mount_path = "/var/log"
            read_only  = true
          }

          volume_mount {
            name       = "var-lib-docker-containers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 9001
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 30
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 9001
            }
            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 3
          }

          security_context {
            run_as_user = 0
            privileged  = false
            capabilities {
              add = ["DAC_READ_SEARCH"]
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.f2-vector-config.metadata[0].name
          }
        }

        volume {
          name = "var-log"
          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "var-lib-docker-containers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        host_network = false
        dns_policy   = "ClusterFirst"

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "f2-vector" {
  metadata {
    name      = "f2-vector-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-vector-${var.environment}"
    }

    port {
      name        = "api"
      port        = 9001
      target_port = 9001
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
