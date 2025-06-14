# Generated from Kubernetes CustomResourceDefinition: recurringjobs.longhorn.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_recurringjobs_longhorn_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.17.1"
      }
      "labels" = {
        "app.kubernetes.io/instance" = "longhorn"
        "app.kubernetes.io/name" = "longhorn"
        "app.kubernetes.io/version" = "v1.9.0"
        "longhorn-manager" = ""
      }
      "name" = "recurringjobs.longhorn.io"
    }
    "spec" = {
      "group" = "longhorn.io"
      "names" = {
        "kind" = "RecurringJob"
        "listKind" = "RecurringJobList"
        "plural" = "recurringjobs"
        "shortNames" = [
          "lhrj",
        ]
        "singular" = "recurringjob"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "description" = "Sets groupings to the jobs. When set to \"default\" group will be added to the volume label when no other job label exist in volume"
              "jsonPath" = ".spec.groups"
              "name" = "Groups"
              "type" = "string"
            },
            {
              "description" = "Should be one of \"backup\" or \"snapshot\""
              "jsonPath" = ".spec.task"
              "name" = "Task"
              "type" = "string"
            },
            {
              "description" = "The cron expression represents recurring job scheduling"
              "jsonPath" = ".spec.cron"
              "name" = "Cron"
              "type" = "string"
            },
            {
              "description" = "The number of snapshots/backups to keep for the volume"
              "jsonPath" = ".spec.retain"
              "name" = "Retain"
              "type" = "integer"
            },
            {
              "description" = "The concurrent job to run by each cron job"
              "jsonPath" = ".spec.concurrency"
              "name" = "Concurrency"
              "type" = "integer"
            },
            {
              "jsonPath" = ".metadata.creationTimestamp"
              "name" = "Age"
              "type" = "date"
            },
            {
              "description" = "Specify the labels"
              "jsonPath" = ".spec.labels"
              "name" = "Labels"
              "type" = "string"
            },
          ]
          "deprecated" = true
          "deprecationWarning" = "longhorn.io/v1beta1 RecurringJob is deprecated; use longhorn.io/v1beta2 RecurringJob instead"
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "RecurringJob is where Longhorn stores recurring job object."
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
                  "x-kubernetes-preserve-unknown-fields" = true
                }
                "status" = {
                  "x-kubernetes-preserve-unknown-fields" = true
                }
              }
              "type" = "object"
            }
          }
          "served" = false
          "storage" = false
          "subresources" = {
            "status" = {}
          }
        },
        {
          "additionalPrinterColumns" = [
            {
              "description" = "Sets groupings to the jobs. When set to \"default\" group will be added to the volume label when no other job label exist in volume"
              "jsonPath" = ".spec.groups"
              "name" = "Groups"
              "type" = "string"
            },
            {
              "description" = "Should be one of \"snapshot\", \"snapshot-force-create\", \"snapshot-cleanup\", \"snapshot-delete\", \"backup\", \"backup-force-create\", \"filesystem-trim\" or \"system-backup\""
              "jsonPath" = ".spec.task"
              "name" = "Task"
              "type" = "string"
            },
            {
              "description" = "The cron expression represents recurring job scheduling"
              "jsonPath" = ".spec.cron"
              "name" = "Cron"
              "type" = "string"
            },
            {
              "description" = "The number of snapshots/backups to keep for the volume"
              "jsonPath" = ".spec.retain"
              "name" = "Retain"
              "type" = "integer"
            },
            {
              "description" = "The concurrent job to run by each cron job"
              "jsonPath" = ".spec.concurrency"
              "name" = "Concurrency"
              "type" = "integer"
            },
            {
              "jsonPath" = ".metadata.creationTimestamp"
              "name" = "Age"
              "type" = "date"
            },
            {
              "description" = "Specify the labels"
              "jsonPath" = ".spec.labels"
              "name" = "Labels"
              "type" = "string"
            },
          ]
          "name" = "v1beta2"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "RecurringJob is where Longhorn stores recurring job object."
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
                  "description" = "RecurringJobSpec defines the desired state of the Longhorn recurring job"
                  "properties" = {
                    "concurrency" = {
                      "description" = "The concurrency of taking the snapshot/backup."
                      "type" = "integer"
                    }
                    "cron" = {
                      "description" = "The cron setting."
                      "type" = "string"
                    }
                    "groups" = {
                      "description" = "The recurring job group."
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "labels" = {
                      "additionalProperties" = {
                        "type" = "string"
                      }
                      "description" = "The label of the snapshot/backup."
                      "type" = "object"
                    }
                    "name" = {
                      "description" = "The recurring job name."
                      "type" = "string"
                    }
                    "parameters" = {
                      "additionalProperties" = {
                        "type" = "string"
                      }
                      "description" = <<-EOT
                      The parameters of the snapshot/backup.
                      Support parameters: "full-backup-interval", "volume-backup-policy".
                      EOT
                      "type" = "object"
                    }
                    "retain" = {
                      "description" = "The retain count of the snapshot/backup."
                      "type" = "integer"
                    }
                    "task" = {
                      "description" = <<-EOT
                      The recurring job task.
                      Can be "snapshot", "snapshot-force-create", "snapshot-cleanup", "snapshot-delete", "backup", "backup-force-create", "filesystem-trim" or "system-backup".
                      EOT
                      "enum" = [
                        "snapshot",
                        "snapshot-force-create",
                        "snapshot-cleanup",
                        "snapshot-delete",
                        "backup",
                        "backup-force-create",
                        "filesystem-trim",
                        "system-backup",
                      ]
                      "type" = "string"
                    }
                  }
                  "type" = "object"
                }
                "status" = {
                  "description" = "RecurringJobStatus defines the observed state of the Longhorn recurring job"
                  "properties" = {
                    "executionCount" = {
                      "description" = "The number of jobs that have been triggered."
                      "type" = "integer"
                    }
                    "ownerID" = {
                      "description" = "The owner ID which is responsible to reconcile this recurring job CR."
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
