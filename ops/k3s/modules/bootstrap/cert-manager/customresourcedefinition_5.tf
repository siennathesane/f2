# Generated from Kubernetes CustomResourceDefinition: orders.acme.cert-manager.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_orders_acme_cert_manager_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "helm.sh/resource-policy" = "keep"
      }
      "labels" = {
        "app" = "cert-manager"
        "app.kubernetes.io/component" = "crds"
        "app.kubernetes.io/instance" = "cert-manager"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "cert-manager"
        "app.kubernetes.io/version" = "v1.18.0"
        "helm.sh/chart" = "cert-manager-v1.18.0"
      }
      "name" = "orders.acme.cert-manager.io"
    }
    "spec" = {
      "group" = "acme.cert-manager.io"
      "names" = {
        "categories" = [
          "cert-manager",
          "cert-manager-acme",
        ]
        "kind" = "Order"
        "listKind" = "OrderList"
        "plural" = "orders"
        "singular" = "order"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".status.state"
              "name" = "State"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.issuerRef.name"
              "name" = "Issuer"
              "priority" = 1
              "type" = "string"
            },
            {
              "jsonPath" = ".status.reason"
              "name" = "Reason"
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
              "description" = "Order is a type to represent an Order with an ACME server"
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
                  "properties" = {
                    "commonName" = {
                      "description" = <<-EOT
                      CommonName is the common name as specified on the DER encoded CSR.
                      If specified, this value must also be present in `dnsNames` or `ipAddresses`.
                      This field must match the corresponding field on the DER encoded CSR.
                      EOT
                      "type" = "string"
                    }
                    "dnsNames" = {
                      "description" = <<-EOT
                      DNSNames is a list of DNS names that should be included as part of the Order
                      validation process.
                      This field must match the corresponding field on the DER encoded CSR.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "duration" = {
                      "description" = <<-EOT
                      Duration is the duration for the not after date for the requested certificate.
                      this is set on order creation as pe the ACME spec.
                      EOT
                      "type" = "string"
                    }
                    "ipAddresses" = {
                      "description" = <<-EOT
                      IPAddresses is a list of IP addresses that should be included as part of the Order
                      validation process.
                      This field must match the corresponding field on the DER encoded CSR.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "issuerRef" = {
                      "description" = <<-EOT
                      IssuerRef references a properly configured ACME-type Issuer which should
                      be used to create this Order.
                      If the Issuer does not exist, processing will be retried.
                      If the Issuer is not an 'ACME' Issuer, an error will be returned and the
                      Order will be marked as failed.
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
                    "profile" = {
                      "description" = <<-EOT
                      Profile allows requesting a certificate profile from the ACME server.
                      Supported profiles are listed by the server's ACME directory URL.
                      EOT
                      "type" = "string"
                    }
                    "request" = {
                      "description" = <<-EOT
                      Certificate signing request bytes in DER encoding.
                      This will be used when finalizing the order.
                      This field must be set on the order.
                      EOT
                      "format" = "byte"
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
                  "properties" = {
                    "authorizations" = {
                      "description" = <<-EOT
                      Authorizations contains data returned from the ACME server on what
                      authorizations must be completed in order to validate the DNS names
                      specified on the Order.
                      EOT
                      "items" = {
                        "description" = <<-EOT
                        ACMEAuthorization contains data returned from the ACME server on an
                        authorization that must be completed in order validate a DNS name on an ACME
                        Order resource.
                        EOT
                        "properties" = {
                          "challenges" = {
                            "description" = <<-EOT
                            Challenges specifies the challenge types offered by the ACME server.
                            One of these challenge types will be selected when validating the DNS
                            name and an appropriate Challenge resource will be created to perform
                            the ACME challenge process.
                            EOT
                            "items" = {
                              "description" = <<-EOT
                              Challenge specifies a challenge offered by the ACME server for an Order.
                              An appropriate Challenge resource can be created to perform the ACME
                              challenge process.
                              EOT
                              "properties" = {
                                "token" = {
                                  "description" = <<-EOT
                                  Token is the token that must be presented for this challenge.
                                  This is used to compute the 'key' that must also be presented.
                                  EOT
                                  "type" = "string"
                                }
                                "type" = {
                                  "description" = <<-EOT
                                  Type is the type of challenge being offered, e.g., 'http-01', 'dns-01',
                                  'tls-sni-01', etc.
                                  This is the raw value retrieved from the ACME server.
                                  Only 'http-01' and 'dns-01' are supported by cert-manager, other values
                                  will be ignored.
                                  EOT
                                  "type" = "string"
                                }
                                "url" = {
                                  "description" = <<-EOT
                                  URL is the URL of this challenge. It can be used to retrieve additional
                                  metadata about the Challenge from the ACME server.
                                  EOT
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "token",
                                "type",
                                "url",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                          }
                          "identifier" = {
                            "description" = "Identifier is the DNS name to be validated as part of this authorization"
                            "type" = "string"
                          }
                          "initialState" = {
                            "description" = <<-EOT
                            InitialState is the initial state of the ACME authorization when first
                            fetched from the ACME server.
                            If an Authorization is already 'valid', the Order controller will not
                            create a Challenge resource for the authorization. This will occur when
                            working with an ACME server that enables 'authz reuse' (such as Let's
                            Encrypt's production endpoint).
                            If not set and 'identifier' is set, the state is assumed to be pending
                            and a Challenge will be created.
                            EOT
                            "enum" = [
                              "valid",
                              "ready",
                              "pending",
                              "processing",
                              "invalid",
                              "expired",
                              "errored",
                            ]
                            "type" = "string"
                          }
                          "url" = {
                            "description" = "URL is the URL of the Authorization that must be completed"
                            "type" = "string"
                          }
                          "wildcard" = {
                            "description" = <<-EOT
                            Wildcard will be true if this authorization is for a wildcard DNS name.
                            If this is true, the identifier will be the *non-wildcard* version of
                            the DNS name.
                            For example, if '*.example.com' is the DNS name being validated, this
                            field will be 'true' and the 'identifier' field will be 'example.com'.
                            EOT
                            "type" = "boolean"
                          }
                        }
                        "required" = [
                          "url",
                        ]
                        "type" = "object"
                      }
                      "type" = "array"
                    }
                    "certificate" = {
                      "description" = <<-EOT
                      Certificate is a copy of the PEM encoded certificate for this Order.
                      This field will be populated after the order has been successfully
                      finalized with the ACME server, and the order has transitioned to the
                      'valid' state.
                      EOT
                      "format" = "byte"
                      "type" = "string"
                    }
                    "failureTime" = {
                      "description" = <<-EOT
                      FailureTime stores the time that this order failed.
                      This is used to influence garbage collection and back-off.
                      EOT
                      "format" = "date-time"
                      "type" = "string"
                    }
                    "finalizeURL" = {
                      "description" = <<-EOT
                      FinalizeURL of the Order.
                      This is used to obtain certificates for this order once it has been completed.
                      EOT
                      "type" = "string"
                    }
                    "reason" = {
                      "description" = <<-EOT
                      Reason optionally provides more information about a why the order is in
                      the current state.
                      EOT
                      "type" = "string"
                    }
                    "state" = {
                      "description" = <<-EOT
                      State contains the current state of this Order resource.
                      States 'success' and 'expired' are 'final'
                      EOT
                      "enum" = [
                        "valid",
                        "ready",
                        "pending",
                        "processing",
                        "invalid",
                        "expired",
                        "errored",
                      ]
                      "type" = "string"
                    }
                    "url" = {
                      "description" = <<-EOT
                      URL of the Order.
                      This will initially be empty when the resource is first created.
                      The Order controller will populate this field when the Order is first processed.
                      This field will be immutable after it is initially set.
                      EOT
                      "type" = "string"
                    }
                  }
                  "type" = "object"
                }
              }
              "required" = [
                "metadata",
                "spec",
              ]
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
