# Generated from Kubernetes MutatingWebhookConfiguration: cnpg-mutating-webhook-configuration
# API Version: admissionregistration.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "mutatingwebhookconfiguration_cnpg_mutating_webhook_configuration" {
  manifest = {
    "apiVersion" = "admissionregistration.k8s.io/v1"
    "kind" = "MutatingWebhookConfiguration"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "cnpg"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "cloudnative-pg"
        "app.kubernetes.io/version" = "1.26.0"
        "helm.sh/chart" = "cloudnative-pg-0.24.0"
      }
      "name" = "cnpg-mutating-webhook-configuration"
    }
    "webhooks" = [
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "cnpg-webhook-service"
            "namespace" = "cnpg-system"
            "path" = "/mutate-postgresql-cnpg-io-v1-backup"
            "port" = 443
          }
        }
        "failurePolicy" = "Fail"
        "name" = "mbackup.cnpg.io"
        "rules" = [
          {
            "apiGroups" = [
              "postgresql.cnpg.io",
            ]
            "apiVersions" = [
              "v1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "backups",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "cnpg-webhook-service"
            "namespace" = "cnpg-system"
            "path" = "/mutate-postgresql-cnpg-io-v1-cluster"
            "port" = 443
          }
        }
        "failurePolicy" = "Fail"
        "name" = "mcluster.cnpg.io"
        "rules" = [
          {
            "apiGroups" = [
              "postgresql.cnpg.io",
            ]
            "apiVersions" = [
              "v1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "clusters",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "cnpg-webhook-service"
            "namespace" = "cnpg-system"
            "path" = "/mutate-postgresql-cnpg-io-v1-database"
            "port" = 443
          }
        }
        "failurePolicy" = "Fail"
        "name" = "mdatabase.cnpg.io"
        "rules" = [
          {
            "apiGroups" = [
              "postgresql.cnpg.io",
            ]
            "apiVersions" = [
              "v1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "databases",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "cnpg-webhook-service"
            "namespace" = "cnpg-system"
            "path" = "/mutate-postgresql-cnpg-io-v1-scheduledbackup"
            "port" = 443
          }
        }
        "failurePolicy" = "Fail"
        "name" = "mscheduledbackup.cnpg.io"
        "rules" = [
          {
            "apiGroups" = [
              "postgresql.cnpg.io",
            ]
            "apiVersions" = [
              "v1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "scheduledbackups",
            ]
          },
        ]
        "sideEffects" = "None"
      },
    ]
  }
}
