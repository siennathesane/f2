resource "kubernetes_manifest" "f2-consolidated-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-consolidated-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        # Open Auth Routes (no auth required) - most specific first
        {
          conditions = [
            {
              prefix = "/auth/v1/verify"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/verify"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            }
          ]
        },
        {
          conditions = [
            {
              prefix = "/auth/v1/callback"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/callback"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            }
          ]
        },
        {
          conditions = [
            {
              prefix = "/auth/v1/authorize"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/authorize"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            }
          ]
        },
        # GraphQL Routes (specific path)
        {
          conditions = [
            {
              prefix = "/graphql/v1"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/rpc/graphql"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-postgrest.metadata[0].name
              port = 3000
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          requestHeadersPolicy = {
            set = [
              {
                name  = "Content-Profile"
                value = "graphql_public"
              }
            ]
          }
        },
        # Realtime REST API (more specific than websocket)
        {
          conditions = [
            {
              prefix = "/realtime/v1/api"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/api"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-realtime.metadata[0].name
              port = 4000
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
        },
        # Realtime WebSocket Routes
        {
          conditions = [
            {
              prefix = "/realtime/v1/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/socket/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-realtime.metadata[0].name
              port = 4000
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          enableWebsockets = true
        },
        # Secured Auth Routes (after open routes)
        {
          conditions = [
            {
              prefix = "/auth/v1/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
        },
        # REST API Routes
        {
          conditions = [
            {
              prefix = "/rest/v1/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-postgrest.metadata[0].name
              port = 3000
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
        },
        # Storage API Routes (no auth - handles its own)
        {
          conditions = [
            {
              prefix = "/storage/v1/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-storage-api.metadata[0].name
              port = 5000
            }
          ]
        },
        # Functions Routes
        {
          conditions = [
            {
              prefix = "/functions/v1/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-functions.metadata[0].name
              port = 9000
            }
          ]
        },
        # Analytics Routes
        {
          conditions = [
            {
              prefix = "/analytics/v1/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-analytics.metadata[0].name
              port = 4000
            }
          ]
        },
        # Meta Routes (admin only)
        {
          conditions = [
            {
              prefix = "/pg/"
            }
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              }
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-meta.metadata[0].name
              port = 8080
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
        },
        # Dashboard Routes (catch-all)
        {
          conditions = [
            {
              prefix = "/"
            }
          ]
          services = [
            {
              name = kubernetes_service_v1.f2-studio.metadata[0].name
              port = 3000
            }
          ]
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-basic-auth.object.metadata.name
              namespace = var.namespace
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "f2-cluster-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-cluster-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      virtualhost = {
        fqdn = "${kubernetes_service_v1.f2-control-plane.metadata[0].name}.${var.namespace}.svc.cluster.local"
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
            "Prefer",
            "Range",
            "Content-Profile"
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
            "PATCH"
          ]
          allowOrigin = [
            "*"
          ]
          maxAge = "24h"
        }
      }
      includes = [{
        name = kubernetes_manifest.f2-consolidated-routes.object.metadata.name
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "f2-internet-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-internet-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      virtualhost = {
        fqdn = var.public-fqdn
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
            "Prefer",
            "Range",
            "Content-Profile"
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
            "PATCH"
          ]
          allowOrigin = [
            "*"
          ]
          maxAge = "24h"
        }
      }
      includes = [{
        name = kubernetes_manifest.f2-consolidated-routes.object.metadata.name
        }
      ]
      routes = [{
        conditions = [
          {
            prefix = "/realtime/v1/"
          }
        ]
        pathRewritePolicy = {
          replacePrefix = [
            {
              replacement = "/socket/"
            }
          ]
        }
        services = [
          {
            name = kubernetes_service_v1.f2-realtime.metadata[0].name
            port = 4000
          }
        ]
        authPolicy = {
          extensionRef = {
            name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
            namespace = var.namespace
          }
        }
        enableWebsockets = true
      }]
    }
  }
}

resource "kubernetes_manifest" "f2-realtime-cluster-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-realtime-cluster-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      virtualhost = {
        fqdn = "*.${kubernetes_service_v1.f2-control-plane.metadata[0].name}.${var.namespace}.svc.cluster.local"
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
            "Prefer",
            "Range",
            "Content-Profile"
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
            "PATCH"
          ]
          allowOrigin = [
            "*"
          ]
          maxAge = "24h"
        }
      }
      includes = [{
        name = kubernetes_manifest.f2-consolidated-routes.object.metadata.name
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "f2-realtime-internet-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-realtime-internet-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      virtualhost = {
        fqdn = "*.${var.public-fqdn}"
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
            "Prefer",
            "Range",
            "Content-Profile"
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
            "PATCH"
          ]
          allowOrigin = [
            "*"
          ]
          maxAge = "24h"
        }
      }
      includes = [{
        name = kubernetes_manifest.f2-consolidated-routes.object.metadata.name
        }
      ]
    }
  }
}

# API Key Auth Extension Service
resource "kubernetes_manifest" "f2-api-key-auth" {
  manifest = {
    apiVersion = "projectcontour.io/v1alpha1"
    kind       = "ExtensionService"
    metadata = {
      name      = "f2-api-key-auth-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      protocol = "h2c"
      services = [
        {
          name = kubernetes_service_v1.f2-auth-middleware.metadata[0].name
          port = 80
        }
      ]
    }
  }
}

# Basic Auth Extension Service
resource "kubernetes_manifest" "f2-basic-auth" {
  manifest = {
    apiVersion = "projectcontour.io/v1alpha1"
    kind       = "ExtensionService"
    metadata = {
      name      = "f2-basic-auth-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      protocol = "h2c"
      services = [
        {
          name = kubernetes_service_v1.f2-auth-middleware.metadata[0].name
          port = 80
        }
      ]
    }
  }
}
