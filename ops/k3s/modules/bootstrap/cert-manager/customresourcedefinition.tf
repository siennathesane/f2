# Generated from Kubernetes CustomResourceDefinition: certificaterequests.cert-manager.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_certificaterequests_cert_manager_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "helm.sh/resource-policy" = "keep"
      }
      "labels" = {
        "app" = "cert-manager"
        "app.kubernetes.io/instance" = "cert-manager"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "cert-manager"
        "app.kubernetes.io/version" = "v1.18.0"
        "helm.sh/chart" = "cert-manager-v1.18.0"
      }
      "name" = "certificaterequests.cert-manager.io"
    }
    "spec" = {
      "group" = "cert-manager.io"
      "names" = {
        "categories" = [
          "cert-manager",
        ]
        "kind" = "CertificateRequest"
        "listKind" = "CertificateRequestList"
        "plural" = "certificaterequests"
        "shortNames" = [
          "cr",
          "crs",
        ]
        "singular" = "certificaterequest"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".status.conditions[?(@.type==\"Approved\")].status"
              "name" = "Approved"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.conditions[?(@.type==\"Denied\")].status"
              "name" = "Denied"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.conditions[?(@.type==\"Ready\")].status"
              "name" = "Ready"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.issuerRef.name"
              "name" = "Issuer"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.username"
              "name" = "Requester"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.conditions[?(@.type==\"Ready\")].message"
              "name" = "Status"
              "priority" = 1
              "type" = "string"
            },
            {
              "description" = "CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC."
              "jsonPath" = ".metadata.creationTimestamp"
              "name" = "Age"
              "type" = "date"
            },
          ]
          "name" = "v1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = <<-EOT
              A CertificateRequest is used to request a signed certificate from one of the
              configured issuers.
              
              All fields within the CertificateRequest's `spec` are immutable after creation.
              A CertificateRequest will either succeed or fail, as denoted by its `Ready` status
              condition and its `status.failureTime` field.
              
              A CertificateRequest is a one-shot resource, meaning it represents a single
              point in time request for a certificate and cannot be re-used.
              EOT
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = <<-EOT
                  Specification of the desired state of the CertificateRequest resource.
                  https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
                  EOT
                  "properties" = {
                    "duration" = {
                      "description" = <<-EOT
                      Requested 'duration' (i.e. lifetime) of the Certificate. Note that the
                      issuer may choose to ignore the requested duration, just like any other
                      requested attribute.
                      EOT
                      "type" = "string"
                    }
                    "extra" = {
                      "additionalProperties" = {
                        "items" = {
                          "type" = "string"
                        }
                        "type" = "array"
                      }
                      "description" = <<-EOT
                      Extra contains extra attributes of the user that created the CertificateRequest.
                      Populated by the cert-manager webhook on creation and immutable.
                      EOT
                      "type" = "object"
                    }
                    "groups" = {
                      "description" = <<-EOT
                      Groups contains group membership of the user that created the CertificateRequest.
                      Populated by the cert-manager webhook on creation and immutable.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                      "x-kubernetes-list-type" = "atomic"
                    }
                    "isCA" = {
                      "description" = <<-EOT
                      Requested basic constraints isCA value. Note that the issuer may choose
                      to ignore the requested isCA value, just like any other requested attribute.
                      
                      NOTE: If the CSR in the `Request` field has a BasicConstraints extension,
                      it must have the same isCA value as specified here.
                      
                      If true, this will automatically add the `cert sign` usage to the list
                      of requested `usages`.
                      EOT
                      "type" = "boolean"
                    }
                    "issuerRef" = {
                      "description" = <<-EOT
                      Reference to the issuer responsible for issuing the certificate.
                      If the issuer is namespace-scoped, it must be in the same namespace
                      as the Certificate. If the issuer is cluster-scoped, it can be used
                      from any namespace.
                      
                      The `name` field of the reference must always be specified.
                      EOT
                      "properties" = {
                        "group" = {
                          "description" = "Group of the resource being referred to."
                          "type" = "string"
                        }
                        "kind" = {
                          "description" = "Kind of the resource being referred to."
                          "type" = "string"
                        }
                        "name" = {
                          "description" = "Name of the resource being referred to."
                          "type" = "string"
                        }
                      }
                      "required" = [
                        "name",
                      ]
                      "type" = "object"
                    }
                    "request" = {
                      "description" = <<-EOT
                      The PEM-encoded X.509 certificate signing request to be submitted to the
                      issuer for signing.
                      
                      If the CSR has a BasicConstraints extension, its isCA attribute must
                      match the `isCA` value of this CertificateRequest.
                      If the CSR has a KeyUsage extension, its key usages must match the
                      key usages in the `usages` field of this CertificateRequest.
                      If the CSR has a ExtKeyUsage extension, its extended key usages
                      must match the extended key usages in the `usages` field of this
                      CertificateRequest.
                      EOT
                      "format" = "byte"
                      "type" = "string"
                    }
                    "uid" = {
                      "description" = <<-EOT
                      UID contains the uid of the user that created the CertificateRequest.
                      Populated by the cert-manager webhook on creation and immutable.
                      EOT
                      "type" = "string"
                    }
                    "usages" = {
                      "description" = <<-EOT
                      Requested key usages and extended key usages.
                      
                      NOTE: If the CSR in the `Request` field has uses the KeyUsage or
                      ExtKeyUsage extension, these extensions must have the same values
                      as specified here without any additional values.
                      
                      If unset, defaults to `digital signature` and `key encipherment`.
                      EOT
                      "items" = {
                        "description" = <<-EOT
                        KeyUsage specifies valid usage contexts for keys.
                        See:
                        https://tools.ietf.org/html/rfc5280#section-4.2.1.3
                        https://tools.ietf.org/html/rfc5280#section-4.2.1.12
                        
                        Valid KeyUsage values are as follows:
                        "signing",
                        "digital signature",
                        "content commitment",
                        "key encipherment",
                        "key agreement",
                        "data encipherment",
                        "cert sign",
                        "crl sign",
                        "encipher only",
                        "decipher only",
                        "any",
                        "server auth",
                        "client auth",
                        "code signing",
                        "email protection",
                        "s/mime",
                        "ipsec end system",
                        "ipsec tunnel",
                        "ipsec user",
                        "timestamping",
                        "ocsp signing",
                        "microsoft sgc",
                        "netscape sgc"
                        EOT
                        "enum" = [
                          "signing",
                          "digital signature",
                          "content commitment",
                          "key encipherment",
                          "key agreement",
                          "data encipherment",
                          "cert sign",
                          "crl sign",
                          "encipher only",
                          "decipher only",
                          "any",
                          "server auth",
                          "client auth",
                          "code signing",
                          "email protection",
                          "s/mime",
                          "ipsec end system",
                          "ipsec tunnel",
                          "ipsec user",
                          "timestamping",
                          "ocsp signing",
                          "microsoft sgc",
                          "netscape sgc",
                        ]
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "username" = {
                      "description" = <<-EOT
                      Username contains the name of the user that created the CertificateRequest.
                      Populated by the cert-manager webhook on creation and immutable.
                      EOT
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "issuerRef",
                    "request",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "description" = <<-EOT
                  Status of the CertificateRequest.
                  This is set and managed automatically.
                  Read-only.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
                  EOT
                  "properties" = {
                    "ca" = {
                      "description" = <<-EOT
                      The PEM encoded X.509 certificate of the signer, also known as the CA
                      (Certificate Authority).
                      This is set on a best-effort basis by different issuers.
                      If not set, the CA is assumed to be unknown/not available.
                      EOT
                      "format" = "byte"
                      "type" = "string"
                    }
                    "certificate" = {
                      "description" = <<-EOT
                      The PEM encoded X.509 certificate resulting from the certificate
                      signing request.
                      If not set, the CertificateRequest has either not been completed or has
                      failed. More information on failure can be found by checking the
                      `conditions` field.
                      EOT
                      "format" = "byte"
                      "type" = "string"
                    }
                    "conditions" = {
                      "description" = <<-EOT
                      List of status conditions to indicate the status of a CertificateRequest.
                      Known condition types are `Ready`, `InvalidRequest`, `Approved` and `Denied`.
                      EOT
                      "items" = {
                        "description" = "CertificateRequestCondition contains condition information for a CertificateRequest."
                        "properties" = {
                          "lastTransitionTime" = {
                            "description" = <<-EOT
                            LastTransitionTime is the timestamp corresponding to the last status
                            change of this condition.
                            EOT
                            "format" = "date-time"
                            "type" = "string"
                          }
                          "message" = {
                            "description" = <<-EOT
                            Message is a human readable description of the details of the last
                            transition, complementing reason.
                            EOT
                            "type" = "string"
                          }
                          "reason" = {
                            "description" = <<-EOT
                            Reason is a brief machine readable explanation for the condition's last
                            transition.
                            EOT
                            "type" = "string"
                          }
                          "status" = {
                            "description" = "Status of the condition, one of (`True`, `False`, `Unknown`)."
                            "enum" = [
                              "True",
                              "False",
                              "Unknown",
                            ]
                            "type" = "string"
                          }
                          "type" = {
                            "description" = <<-EOT
                            Type of the condition, known values are (`Ready`, `InvalidRequest`,
                            `Approved`, `Denied`).
                            EOT
                            "type" = "string"
                          }
                        }
                        "required" = [
                          "status",
                          "type",
                        ]
                        "type" = "object"
                      }
                      "type" = "array"
                      "x-kubernetes-list-map-keys" = [
                        "type",
                      ]
                      "x-kubernetes-list-type" = "map"
                    }
                    "failureTime" = {
                      "description" = <<-EOT
                      FailureTime stores the time that this CertificateRequest failed. This is
                      used to influence garbage collection and back-off.
                      EOT
                      "format" = "date-time"
                      "type" = "string"
                    }
                  }
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}
