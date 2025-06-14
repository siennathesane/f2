resource "kubernetes_secret_v1" "f2-functions-config" {
  metadata {
    name      = "f2-functions-config-${var.environment}"
    namespace = var.namespace
  }

  data = {
    # todo(siennathesane): fix this
    supabase_db_url = "postgresql://postgres:${kubernetes_secret_v1.f2-db-admin.data.password}@${kubectl_manifest.f2-cluster.name}-rw:5432/${local.f2-control-plane-db-name}"
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "f2-functions-config" {
  metadata {
    name      = "f2-functions-config-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-functions-${var.environment}"
    }
  }

  data = {
    SUPABASE_URL = "http://${kubernetes_service_v1.f2-control-plane.metadata[0].name}"
    VERIFY_JWT   = "true"
  }
}

# runtime API handler
resource "kubernetes_config_map_v1" "f2-functions-code" {
  metadata {
    name      = "f2-functions-code-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-functions-${var.environment}"
    }
  }

  data = {
    "index.ts" = <<-EOT
    import { serve } from 'https://deno.land/std@0.131.0/http/server.ts'
    import * as jose from 'https://deno.land/x/jose@v4.14.4/index.ts'

    console.log('main function started')

    const JWT_SECRET = Deno.env.get('JWT_SECRET')
    const VERIFY_JWT = Deno.env.get('VERIFY_JWT') === 'true'

    function getAuthToken(req: Request) {
      const authHeader = req.headers.get('authorization')
      if (!authHeader) {
        throw new Error('Missing authorization header')
      }
      const [bearer, token] = authHeader.split(' ')
      if (bearer !== 'Bearer') {
        throw new Error(`Auth header is not 'Bearer {token}'`)
      }
      return token
    }

    async function verifyJWT(jwt: string): Promise<boolean> {
      const encoder = new TextEncoder()
      const secretKey = encoder.encode(JWT_SECRET)
      try {
        await jose.jwtVerify(jwt, secretKey)
      } catch (err) {
        console.error(err)
        return false
      }
      return true
    }

    serve(async (req: Request) => {
      const healthCheck = req.headers.get('health-check')
      if (healthCheck === 'true') {
          return new Response(JSON.stringify({ status: 'healthy' }), {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
        })
      }
      if (req.method !== 'OPTIONS' && VERIFY_JWT) {
        try {
          const token = getAuthToken(req)
          const isValidJWT = await verifyJWT(token)

          if (!isValidJWT) {
            return new Response(JSON.stringify({ msg: 'Invalid JWT' }), {
              status: 401,
              headers: { 'Content-Type': 'application/json' },
            })
          }
        } catch (e) {
          console.error(e)
          return new Response(JSON.stringify({ msg: e.toString() }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' },
          })
        }
      }

      const url = new URL(req.url)
      const { pathname } = url
      const path_parts = pathname.split('/')
      const service_name = path_parts[1]

      if (!service_name || service_name === '') {
        const error = { msg: 'missing function name in request' }
        return new Response(JSON.stringify(error), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        })
      }

      const servicePath = `/home/deno/functions/$${service_name}`
      console.error(`serving the request with $${servicePath}`)

      const memoryLimitMb = 150
      const workerTimeoutMs = 1 * 60 * 1000
      const noModuleCache = false
      const importMapPath = null
      const envVarsObj = Deno.env.toObject()
      const envVars = Object.keys(envVarsObj).map((k) => [k, envVarsObj[k]])

      try {
        const worker = await EdgeRuntime.userWorkers.create({
          servicePath,
          memoryLimitMb,
          workerTimeoutMs,
          noModuleCache,
          importMapPath,
          envVars,
        })
        return await worker.fetch(req)
      } catch (e) {
        const error = { msg: e.toString() }
        return new Response(JSON.stringify(error), {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        })
      }
    })
EOT
  }
}

resource "kubernetes_deployment_v1" "f2-functions" {
  timeouts {
    create = "2m"
    update = "2m"
  }

  metadata {
    name      = "f2-functions-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-functions-${var.environment}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "f2.pub/app" = "f2-functions-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          "f2.pub/app" = "f2-functions-${var.environment}"
        }
      }

      spec {
        init_container {
          name    = "setup-functions"
          image   = "busybox:1.35"
          command = ["sh", "-c"]
          args = [
            "mkdir -p /functions/main && cp /tmp/functions/index.ts /functions/main/index.ts && chmod -R 644 /functions"
          ]

          volume_mount {
            name       = "functions-code-temp"
            mount_path = "/tmp/functions"
            read_only  = true
          }
          volume_mount {
            name       = "functions-code"
            mount_path = "/functions"
          }
        }

        container {
          name  = "f2-functions"
          image = "supabase/edge-runtime:v1.67.4"

          command = [
            "edge-runtime",
            "start",
            "--main-service",
            "/functions/main"
          ]

          volume_mount {
            name       = "functions-code"
            mount_path = "/functions"
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          port {
            name           = "http"
            container_port = 9000
            protocol       = "TCP"
          }

          env {
            name  = "EDGE_RUNTIME_PORT"
            value = "9000"
          }

          # Environment variables from ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.f2-functions-config.metadata[0].name
            }
          }

          # Sensitive environment variables from Secret
          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "secret"
              }
            }
          }

          env {
            name = "SUPABASE_ANON_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "anonKey"
              }
            }
          }

          env {
            name = "SUPABASE_SERVICE_ROLE_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-auth-jwt.metadata[0].name
                key  = "serviceKey"
              }
            }
          }

          env {
            name = "SUPABASE_DB_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.f2-functions-config.metadata[0].name
                key  = "supabase_db_url"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "9000"
              http_header {
                name  = "Health-Check"
                value = "true"
              }
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 30
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "9000"
              http_header {
                name  = "Health-Check"
                value = "true"
              }
            }
            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 3
          }

          startup_probe {
            http_get {
              path = "/"
              port = "9000"
              http_header {
                name  = "Health-Check"
                value = "true"
              }
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 5
            failure_threshold     = 12
          }
        }

        volume {
          name = "functions-code"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.f2-functions-storage.metadata[0].name
          }
        }

        volume {
          name = "functions-code-temp"
          config_map {
            name = kubernetes_config_map_v1.f2-functions-code.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "f2-functions-storage" {
  metadata {
    name      = "f2-functions-storage-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-functions-${var.environment}"
    }
  }

  wait_until_bound = false
  # todo(siennathesane): implement ReadWriteMany later
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "local-path"
  }
}

resource "kubernetes_service_v1" "f2-functions" {
  metadata {
    name      = "f2-functions-${var.environment}"
    namespace = var.namespace
    labels = {
      "f2.pub/app" = "f2-functions-${var.environment}"
    }
  }

  spec {
    selector = {
      "f2.pub/app" = "f2-functions-${var.environment}"
    }

    port {
      name        = "http"
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
