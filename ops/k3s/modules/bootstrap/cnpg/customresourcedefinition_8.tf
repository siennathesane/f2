# Generated from Kubernetes CustomResourceDefinition: subscriptions.postgresql.cnpg.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_subscriptions_postgresql_cnpg_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.17.3"
        "helm.sh/resource-policy" = "keep"
      }
      "name" = "subscriptions.postgresql.cnpg.io"
    }
    "spec" = {
      "group" = "postgresql.cnpg.io"
      "names" = {
        "kind" = "Subscription"
        "listKind" = "SubscriptionList"
        "plural" = "subscriptions"
        "singular" = "subscription"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".metadata.creationTimestamp"
              "name" = "Age"
              "type" = "date"
            },
            {
              "jsonPath" = ".spec.cluster.name"
              "name" = "Cluster"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.name"
              "name" = "PG Name"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.applied"
              "name" = "Applied"
              "type" = "boolean"
            },
            {
              "description" = "Latest reconciliation message"
              "jsonPath" = ".status.message"
              "name" = "Message"
              "type" = "string"
            },
          ]
          "name" = "v1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "Subscription is the Schema for the subscriptions API"
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
                  "description" = "SubscriptionSpec defines the desired state of Subscription"
                  "properties" = {
                    "cluster" = {
                      "description" = "The name of the PostgreSQL cluster that identifies the \"subscriber\""
                      "properties" = {
                        "name" = {
                          "default" = ""
                          "description" = <<-EOT
                          Name of the referent.
                          This field is effectively required, but due to backwards compatibility is
                          allowed to be empty. Instances of this type with an empty value here are
                          almost certainly wrong.
                          More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                          EOT
                          "type" = "string"
                        }
                      }
                      "type" = "object"
                      "x-kubernetes-map-type" = "atomic"
                    }
                    "dbname" = {
                      "description" = <<-EOT
                      The name of the database where the publication will be installed in
                      the "subscriber" cluster
                      EOT
                      "type" = "string"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "dbname is immutable"
                          "rule" = "self == oldSelf"
                        },
                      ]
                    }
                    "externalClusterName" = {
                      "description" = "The name of the external cluster with the publication (\"publisher\")"
                      "type" = "string"
                    }
                    "name" = {
                      "description" = "The name of the subscription inside PostgreSQL"
                      "type" = "string"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "name is immutable"
                          "rule" = "self == oldSelf"
                        },
                      ]
                    }
                    "parameters" = {
                      "additionalProperties" = {
                        "type" = "string"
                      }
                      "description" = <<-EOT
                      Subscription parameters part of the `WITH` clause as expected by
                      PostgreSQL `CREATE SUBSCRIPTION` command
                      EOT
                      "type" = "object"
                    }
                    "publicationDBName" = {
                      "description" = <<-EOT
                      The name of the database containing the publication on the external
                      cluster. Defaults to the one in the external cluster definition.
                      EOT
                      "type" = "string"
                    }
                    "publicationName" = {
                      "description" = <<-EOT
                      The name of the publication inside the PostgreSQL database in the
                      "publisher"
                      EOT
                      "type" = "string"
                    }
                    "subscriptionReclaimPolicy" = {
                      "default" = "retain"
                      "description" = "The policy for end-of-life maintenance of this subscription"
                      "enum" = [
                        "delete",
                        "retain",
                      ]
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "cluster",
                    "dbname",
                    "externalClusterName",
                    "name",
                    "publicationName",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "description" = "SubscriptionStatus defines the observed state of Subscription"
                  "properties" = {
                    "applied" = {
                      "description" = "Applied is true if the subscription was reconciled correctly"
                      "type" = "boolean"
                    }
                    "message" = {
                      "description" = "Message is the reconciliation output message"
                      "type" = "string"
                    }
                    "observedGeneration" = {
                      "description" = <<-EOT
                      A sequence number representing the latest
                      desired state that was synchronized
                      EOT
                      "format" = "int64"
                      "type" = "integer"
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
