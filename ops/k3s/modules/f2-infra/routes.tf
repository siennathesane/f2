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
        },
      ]
    }
  }
}

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
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "f2-auth-open-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-auth-open-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          conditions = [
            {
              prefix = "/auth/v1/verify"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/verify"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            },
          ]
        },
        {
          conditions = [
            {
              prefix = "/auth/v1/callback"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/callback"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            },
          ]
        },
        {
          conditions = [
            {
              prefix = "/auth/v1/authorize"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/authorize"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              port = 9999
            },
          ]
        },
      ]
      virtualhost = {
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
          ]
          allowOrigin = [
            "*",
          ]
          maxAge = "24h"
        }
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-auth-secured-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-auth-secured-routes-${var.namespace}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          conditions = [
            {
              prefix = "/auth/v1/"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              },
            ]
          }
          services = [
            {
              "name" = kubernetes_service_v1.f2-auth-svc.metadata[0].name
              "port" = 9999
            },
          ]
        },
      ]
      virtualhost = {
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
          ]
          allowOrigin = [
            "*",
          ]
          maxAge = "24h"
        }
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-rest-api-route" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-rest-api-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          authPolicy = {
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          conditions = [
            {
              prefix = "/rest/v1/"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              },
            ]
          }
          services = [
            {
              "name" = "rest"
              "port" = 3000
            },
          ]
        },
      ]
      virtualhost = {
        corsPolicy = {
          allowCredentials = true
          allowHeaders = [
            "Content-Type",
            "Authorization",
            "apikey",
            "Prefer",
            "Range",
          ]
          allowMethods = [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "OPTIONS",
            "PATCH",
          ]
          allowOrigin = [
            "*",
          ]
          maxAge = "24h"
        }
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-graphql-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      annotations = {
        "projectcontour.io/request-headers"  = <<-EOT
        Content-Profile: graphql_public

        EOT
        "projectcontour.io/response-headers" = <<-EOT
        Access-Control-Allow-Origin: "*"
        Access-Control-Allow-Methods: "GET, POST, OPTIONS"
        Access-Control-Allow-Headers: "Content-Type, Authorization, apikey"

        EOT
      }
      name      = "f2-graphql-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          authPolicy = {
            context = {
              apikey = "header"
            }
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          conditions = [
            {
              prefix = "/graphql/v1"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/rpc/graphql"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-postgrest.metadata[0].name
              port = 3000
            },
          ]
        },
      ]
      virtualhost = {
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-realtime-websocket-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      annotations = {
        "projectcontour.io/response-headers" = <<-EOT
        Access-Control-Allow-Origin: "*"
        Access-Control-Allow-Methods: "GET, POST, OPTIONS"
        Access-Control-Allow-Headers: "Content-Type, Authorization, apikey"

        EOT
        "projectcontour.io/websocket-routes" = "true"
      }
      name      = "f2-realtime-ws-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          authPolicy = {
            context = {
              apikey = "header"
            }
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          conditions = [
            {
              prefix = "/realtime/v1/"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/socket/"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-realtime.metadata[0].name
              port = 4000
            },
          ]
        },
      ]
      virtualhost = {
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-realtime-rest-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      annotations = {
        "projectcontour.io/response-headers" = <<-EOT
        Access-Control-Allow-Origin: "*"
        Access-Control-Allow-Methods: "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers: "Content-Type, Authorization, apikey"

        EOT
      }
      name      = "f-2realtime-rest-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          authPolicy = {
            context = {
              apikey = "header"
            }
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          conditions = [
            {
              prefix = "/realtime/v1/api"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/api"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-realtime.metadata[0].name
              port = 4000
            },
          ]
        },
      ]
      virtualhost = {
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-storage-api-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      annotations = {
        "projectcontour.io/response-headers" = <<-EOT
        Access-Control-Allow-Origin: "*"
        Access-Control-Allow-Methods: "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers: "Content-Type, Authorization, apikey"

        EOT
      }
      name      = "f2-storage-api-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          conditions = [
            {
              prefix = "/storage/v1/"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-storage-api.metadata[0].name
              port = 5000
            },
          ]
        },
      ]
      virtualhost = {
        fqdn = var.public-url
      }
    }
  }
}

# todo(siennathesane): open this up after deploying functions.
# resource "kubernetes_manifest" "f2-functions-route"{
#   manifest = {
#     apiVersion = "projectcontour.io/v1"
#     kind = "HTTPProxy"
#     metadata = {
#       annotations = {
#         "projectcontour.io/response-headers" = <<-EOT
#         Access-Control-Allow-Origin: "*"
#         Access-Control-Allow-Methods: "GET, POST, PUT, DELETE, OPTIONS"
#         Access-Control-Allow-Headers: "Content-Type, Authorization, apikey"

#         EOT
#       }
#       name = "f2-functions-routes-${var.environment}"
#       namespace = var.namespace
#     }
#     spec = {
#       routes = [
#         {
#           conditions = [
#             {
#               prefix = "/functions/v1/"
#             },
#           ]
#           pathRewritePolicy = {
#             replacePrefix = [
#               {
#                 replacement = "/"
#               },
#             ]
#           }
#           services = [
#             {
#               name = "functions"
#               port = 9000
#             },
#           ]
#         },
#       ]
#       virtualhost = {
#         fqdn = "your-domain.com"
#       }
#     }
#   }
# }

resource "kubernetes_manifest" "f2-analytics-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-analytics-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          conditions = [
            {
              prefix = "/analytics/v1/"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-analytics.metadata[0].name
              port = 4000
            },
          ]
        },
      ]
      virtualhost = {
        fqdn = var.public-url
      }
    }
  }
}

resource "kubernetes_manifest" "f2-meta-routes" {
  manifest = {
    apiVersion = "projectcontour.io/v1"
    kind       = "HTTPProxy"
    metadata = {
      name      = "f2-meta-routes-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      routes = [
        {
          authPolicy = {
            context = {
              apikey = "header"
              role   = "admin"
            }
            extensionRef = {
              name      = kubernetes_manifest.f2-api-key-auth.object.metadata.name
              namespace = var.namespace
            }
          }
          conditions = [
            {
              prefix = "/pg/"
            },
          ]
          pathRewritePolicy = {
            replacePrefix = [
              {
                replacement = "/"
              },
            ]
          }
          services = [
            {
              name = kubernetes_service_v1.f2-meta.metadata[0].name
              port = 8080
            },
          ]
        },
      ]
      virtualhost = {
        fqdn = var.public-url
      }
    }
  }
}

# todo(siennathesane): undo this after studio has been deployed
# resource "kubernetes_manifest" "f2-dashboard-routes" {
#   manifest = {
#     apiVersion = "projectcontour.io/v1"
#     kind = "HTTPProxy"
#     metadata = {
#       name = "f2-dashboard-routes"
#       namespace = "supabase"
#     }
#     spec = {
#       routes = [
#         {
#           authPolicy = {
#             extensionRef = {
#               name = "basic-auth"
#               namespace = "supabase"
#             }
#           }
#           conditions = [
#             {
#               prefix = "/"
#             },
#           ]
#           services = [
#             {
#               name = "studio"
#               port = 3000
#             },
#           ]
#         },
#       ]
#       virtualhost = {
#         corsPolicy = {
#           allowCredentials = true
#           allowHeaders = [
#             "Content-Type",
#             "Authorization",
#           ]
#           allowMethods = [
#             "GET",
#             "POST",
#             "OPTIONS",
#           ]
#           allowOrigin = [
#             "*",
#           ]
#           maxAge = "24h"
#         }
#         fqdn = "your-domain.com"
#       }
#     }
#   }
# }
