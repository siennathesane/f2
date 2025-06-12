# Generated from Kubernetes CustomResourceDefinition: scheduledbackups.postgresql.cnpg.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_scheduledbackups_postgresql_cnpg_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.17.3"
        "helm.sh/resource-policy" = "keep"
      }
      "name" = "scheduledbackups.postgresql.cnpg.io"
    }
    "spec" = {
      "group" = "postgresql.cnpg.io"
      "names" = {
        "kind" = "ScheduledBackup"
        "listKind" = "ScheduledBackupList"
        "plural" = "scheduledbackups"
        "singular" = "scheduledbackup"
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
              "jsonPath" = ".status.lastScheduleTime"
              "name" = "Last Backup"
              "type" = "date"
            },
          ]
          "name" = "v1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "ScheduledBackup is the Schema for the scheduledbackups API"
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
                  Specification of the desired behavior of the ScheduledBackup.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
                  EOT
                  "properties" = {
                    "backupOwnerReference" = {
                      "default" = "none"
                      "description" = <<-EOT
                      Indicates which ownerReference should be put inside the created backup resources.<br />
                      - none: no owner reference for created backup objects (same behavior as before the field was introduced)<br />
                      - self: sets the Scheduled backup object as owner of the backup<br />
                      - cluster: set the cluster as owner of the backup<br />
                      EOT
                      "enum" = [
                        "none",
                        "self",
                        "cluster",
                      ]
                      "type" = "string"
                    }
                    "cluster" = {
                      "description" = "The cluster to backup"
                      "properties" = {
                        "name" = {
                          "description" = "Name of the referent."
                          "type" = "string"
                        }
                      }
                      "required" = [
                        "name",
                      ]
                      "type" = "object"
                    }
                    "immediate" = {
                      "description" = "If the first backup has to be immediately start after creation or not"
                      "type" = "boolean"
                    }
                    "method" = {
                      "default" = "barmanObjectStore"
                      "description" = <<-EOT
                      The backup method to be used, possible options are `barmanObjectStore`,
                      `volumeSnapshot` or `plugin`. Defaults to: `barmanObjectStore`.
                      EOT
                      "enum" = [
                        "barmanObjectStore",
                        "volumeSnapshot",
                        "plugin",
                      ]
                      "type" = "string"
                    }
                    "online" = {
                      "description" = <<-EOT
                      Whether the default type of backup with volume snapshots is
                      online/hot (`true`, default) or offline/cold (`false`)
                      Overrides the default setting specified in the cluster field '.spec.backup.volumeSnapshot.online'
                      EOT
                      "type" = "boolean"
                    }
                    "onlineConfiguration" = {
                      "description" = <<-EOT
                      Configuration parameters to control the online/hot backup with volume snapshots
                      Overrides the default settings specified in the cluster '.backup.volumeSnapshot.onlineConfiguration' stanza
                      EOT
                      "properties" = {
                        "immediateCheckpoint" = {
                          "description" = <<-EOT
                          Control whether the I/O workload for the backup initial checkpoint will
                          be limited, according to the `checkpoint_completion_target` setting on
                          the PostgreSQL server. If set to true, an immediate checkpoint will be
                          used, meaning PostgreSQL will complete the checkpoint as soon as
                          possible. `false` by default.
                          EOT
                          "type" = "boolean"
                        }
                        "waitForArchive" = {
                          "default" = true
                          "description" = <<-EOT
                          If false, the function will return immediately after the backup is completed,
                          without waiting for WAL to be archived.
                          This behavior is only useful with backup software that independently monitors WAL archiving.
                          Otherwise, WAL required to make the backup consistent might be missing and make the backup useless.
                          By default, or when this parameter is true, pg_backup_stop will wait for WAL to be archived when archiving is
                          enabled.
                          On a standby, this means that it will wait only when archive_mode = always.
                          If write activity on the primary is low, it may be useful to run pg_switch_wal on the primary in order to trigger
                          an immediate segment switch.
                          EOT
                          "type" = "boolean"
                        }
                      }
                      "type" = "object"
                    }
                    "pluginConfiguration" = {
                      "description" = "Configuration parameters passed to the plugin managing this backup"
                      "properties" = {
                        "name" = {
                          "description" = "Name is the name of the plugin managing this backup"
                          "type" = "string"
                        }
                        "parameters" = {
                          "additionalProperties" = {
                            "type" = "string"
                          }
                          "description" = <<-EOT
                          Parameters are the configuration parameters passed to the backup
                          plugin for this backup
                          EOT
                          "type" = "object"
                        }
                      }
                      "required" = [
                        "name",
                      ]
                      "type" = "object"
                    }
                    "schedule" = {
                      "description" = <<-EOT
                      The schedule does not follow the same format used in Kubernetes CronJobs
                      as it includes an additional seconds specifier,
                      see https://pkg.go.dev/github.com/robfig/cron#hdr-CRON_Expression_Format
                      EOT
                      "type" = "string"
                    }
                    "suspend" = {
                      "description" = "If this backup is suspended or not"
                      "type" = "boolean"
                    }
                    "target" = {
                      "description" = <<-EOT
                      The policy to decide which instance should perform this backup. If empty,
                      it defaults to `cluster.spec.backup.target`.
                      Available options are empty string, `primary` and `prefer-standby`.
                      `primary` to have backups run always on primary instances,
                      `prefer-standby` to have backups run preferably on the most updated
                      standby, if available.
                      EOT
                      "enum" = [
                        "primary",
                        "prefer-standby",
                      ]
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "cluster",
                    "schedule",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "description" = <<-EOT
                  Most recently observed status of the ScheduledBackup. This data may not be up
                  to date. Populated by the system. Read-only.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
                  EOT
                  "properties" = {
                    "lastCheckTime" = {
                      "description" = "The latest time the schedule"
                      "format" = "date-time"
                      "type" = "string"
                    }
                    "lastScheduleTime" = {
                      "description" = "Information when was the last time that backup was successfully scheduled."
                      "format" = "date-time"
                      "type" = "string"
                    }
                    "nextScheduleTime" = {
                      "description" = "Next time we will run a backup"
                      "format" = "date-time"
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
