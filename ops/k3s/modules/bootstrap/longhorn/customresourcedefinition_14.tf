# Generated from Kubernetes CustomResourceDefinition: settings.longhorn.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_settings_longhorn_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind"       = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.17.1"
      }
      "labels" = {
        "app.kubernetes.io/instance" = "longhorn"
        "app.kubernetes.io/name"     = "longhorn"
        "app.kubernetes.io/version"  = "v1.9.0"
        "longhorn-manager"           = ""
      }
      "name" = "settings.longhorn.io"
    }
    "spec" = {
      "group" = "longhorn.io"
      "names" = {
        "kind"     = "Setting"
        "listKind" = "SettingList"
        "plural"   = "settings"
        "shortNames" = [
          "lhs",
        ]
        "singular" = "setting"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "description" = "The value of the setting"
              "jsonPath"    = ".value"
              "name"        = "Value"
              "type"        = "string"
            },
            {
              "jsonPath" = ".metadata.creationTimestamp"
              "name"     = "Age"
              "type"     = "date"
            },
          ]
          "deprecated"         = true
          "deprecationWarning" = "longhorn.io/v1beta1 Setting is deprecated; use longhorn.io/v1beta2 Setting instead"
          "name"               = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "Setting is where Longhorn stores setting object."
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type"        = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type"        = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "value" = {
                  "type" = "string"
                }
              }
              "required" = [
                "value",
              ]
              "type" = "object"
            }
          }
          "served"  = false
          "storage" = false
          "subresources" = {
            "status" = {}
          }
        },
        {
          "additionalPrinterColumns" = [
            {
              "description" = "The value of the setting"
              "jsonPath"    = ".value"
              "name"        = "Value"
              "type"        = "string"
            },
            {
              "description" = "The setting is applied"
              "jsonPath"    = ".status.applied"
              "name"        = "Applied"
              "type"        = "boolean"
            },
            {
              "jsonPath" = ".metadata.creationTimestamp"
              "name"     = "Age"
              "type"     = "date"
            },
          ]
          "name" = "v1beta2"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "Setting is where Longhorn stores setting object."
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type"        = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type"        = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "status" = {
                  "description" = "The status of the setting."
                  "properties" = {
                    "applied" = {
                      "description" = "The setting is applied."
                      "type"        = "boolean"
                    }
                  }
                  "required" = [
                    "applied",
                  ]
                  "type" = "object"
                }
                "value" = {
                  "description" = "The value of the setting."
                  "type"        = "string"
                }
              }
              "required" = [
                "value",
              ]
              "type" = "object"
            }
          }
          "served"  = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}
