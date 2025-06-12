# resource "kubernetes_manifest" "self-signed-issuer" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "ClusterIssuer"
#     "metadata" = {
#       "name" = "self-signed-issuer"
#     }
#     "spec" = {
#       "selfSigned" = {}
#     }
#   }
# }

# resource "kubernetes_manifest" "root-ca" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "Certificate"
#     "metadata" = {
#       "name"      = "root-ca"
#       "namespace" = var.environment
#     }
#     "spec" = {
#       "commonName" = "root-ca"
#       "isCA"       = true
#       "issuerRef" = {
#         "group" = "cert-manager.io"
#         "kind"  = "ClusterIssuer"
#         "name"  = "self-signed-issuer"
#       }
#       "privateKey" = {
#         "algorithm" = "ECDSA"
#         "size"      = 256
#       }
#       "secretName" = "root-ca"
#     }
#   }
# }

# resource "kubernetes_manifest" "root-ca-issuer" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "ClusterIssuer"
#     "metadata" = {
#       "name" = "root-ca-issuer"
#     }
#     "spec" = {
#       "ca" = {
#         "secretName" = "root-ca"
#       }
#     }
#   }
# }
