resource "kubernetes_manifest" "f2-cluster" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = "postgres-${var.environment}"
      "namespace" = var.namespace
    }
    "spec" = {
      "bootstrap" = {
        "initdb" = {
          "database" = "bootstrap"
          "owner"    = kubernetes_secret_v1.f2-bootstrap.data.username
          "secret" = {
            "name" = kubernetes_secret_v1.f2-bootstrap.metadata[0].name
          }
        }
      }
      "managed" = {
        "roles" = [{
          "name" = kubernetes_secret_v1.f2-auth-db.data.username
          "login" = true
          "superuser" = true
          "passwordSecret" = {
            "name" = kubernetes_secret_v1.f2-auth-db.metadata[0].name
          }
        },
        {
          "name" = kubernetes_secret_v1.f2-analytics-db.data.username
          "login" = true
          "superuser" = true
          "passwordSecret" = {
            "name" = kubernetes_secret_v1.f2-analytics-db.metadata[0].name
          }
        }
        ]
      }
      "instances" = 3
      "storage" = {
        "size" = "1Gi"
      }
    }
  }
}

resource "kubernetes_secret_v1" "f2-bootstrap" {
  metadata {
    name = "f2-bootstrap-${var.environment}"
    namespace = var.namespace
  }

  data = {
    password = random_password.f2-bootstrap.result
    username = "postgres"
  }

  type = "kubernetes.io/basic-auth"
}

resource "random_password" "f2-bootstrap" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
