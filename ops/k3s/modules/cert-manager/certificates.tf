resource "kubernetes_manifest" "self-signed-issuer" {
  depends_on = [helm_release.cert-manager]
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "self-signed-issuer"
    }
    "spec" = {
      "selfSigned" = {}
    }
  }
}

resource "kubernetes_manifest" "root-ca" {
  depends_on = [kubernetes_manifest.self-signed-issuer]
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "root-ca"
      "namespace" = kubernetes_namespace.cert-manager.metadata[0].name
    }
    "spec" = {
      "commonName" = "root-ca"
      "isCA"       = true
      "issuerRef" = {
        "group" = "cert-manager.io"
        "kind"  = "ClusterIssuer"
        "name"  = "self-signed-issuer"
      }
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size"      = 256
      }
      "secretName" = "root-ca"
    }
  }
}

resource "kubernetes_manifest" "root-ca-issuer" {
  depends_on = [helm_release.cert-manager]
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "root-ca-issuer"
    }
    "spec" = {
      "ca" = {
        "secretName" = "root-ca"
      }
    }
  }
}

# resource "kubernetes_manifest" "cockroachdb-sql-pod-cert" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "Certificate"
#     "metadata" = {
#       "name"      = "cockroachdb-sql-pod"
#       "namespace" = kubernetes_namespace.cockroachdb.metadata[0].name
#     }
#     "spec" = {
#       "commonName" = "root"
#       "issuerRef" = {
#         "kind" = "ClusterIssuer"
#         "name" = kubernetes_manifest.cockroachdb-ca-issuer.object.metadata.name
#       }
#       "secretName" = "cockroachdb-sql-pod"
#       "subject" = {
#         "organizations" = [
#           "Cockroach",
#         ]
#       }
#       "usages" = [
#         "digital signature",
#         "key encipherment",
#         "client auth",
#       ]
#     }
#   }
# }

# resource "kubernetes_pod_v1" "cockroachdb-secure-sql-pod" {
#   depends_on = [kubernetes_manifest.cockroachdb-sql-pod-cert]
#   metadata {
#     name      = "cockroachdb-secure-sql-pod"
#     namespace = kubernetes_namespace.cockroachdb.metadata[0].name
#   }
#   spec {
#     container {
#       command = [
#         "sleep",
#         "2147483648",
#       ]
#       image             = "cockroachdb/cockroach:v25.2.0"
#       image_pull_policy = "IfNotPresent"
#       name              = "cockroachdb-secure-sql-pod"
#       volume_mount {
#         mount_path = "/cockroach/cockroach-certs/"
#         name       = "client-certs"
#       }
#     }
#     service_account_name             = "cockroachdb"
#     termination_grace_period_seconds = 300
#     volume {
#       name = "client-certs"
#       projected {
#         sources {
#           secret {
#             items {
#               key  = "ca.crt"
#               path = "ca.crt"
#             }
#             items {
#               key  = "tls.crt"
#               path = "client.root.crt"
#             }
#             items {
#               key  = "tls.key"
#               path = "client.root.key"
#             }

#             name = "cockroachdb-sql-pod"
#           }
#         }
#       }
#     }
#   }
# }
