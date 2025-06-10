locals {
  f2-control-plane-db-name = "f2-control-db-${var.environment}"
}

resource "kubernetes_manifest" "f2-cluster" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = "f2-postgres-${var.environment}"
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
        "roles" = [
          {
            "name"      = kubernetes_secret_v1.f2-db-admin.data.username
            "login"     = true
            "superuser" = true
            "passwordSecret" = {
              "name" = kubernetes_secret_v1.f2-db-admin.metadata[0].name
            }
          },
          {
            "name"      = kubernetes_secret_v1.f2-auth-config.data.username
            "login"     = true
            "superuser" = false
            "passwordSecret" = {
              "name" = kubernetes_secret_v1.f2-auth-config.metadata[0].name
            }
          },
          {
            "name"      = kubernetes_secret_v1.f2-analytics-db.data.username
            "login"     = true
            "superuser" = false
            "passwordSecret" = {
              "name" = kubernetes_secret_v1.f2-analytics-db.metadata[0].name
            }
          },
          {
            "name"      = kubernetes_secret_v1.f2-realtime-db.data.username
            "login"     = true
            "superuser" = false
            "passwordSecret" = {
              "name" = kubernetes_secret_v1.f2-realtime-db.metadata[0].name
            }
          },
          {
            "name"      = kubernetes_secret_v1.f2-postgrest-creds.data.username
            "login"     = true
            "superuser" = false
            "passwordSecret" = {
              "name" = kubernetes_secret_v1.f2-postgrest-creds.metadata[0].name
            }
          },
          {
            "name"      = kubernetes_secret_v1.f2-postgrest-creds.data.anon_username
            "login"     = false
            "superuser" = false
          },
          {
            "name"      = kubernetes_secret_v1.f2-postgrest-creds.data.web_username
            "login"     = false
            "superuser" = false
          },
        ]
      }
      "instances" = 1
      "storage" = {
        "size" = "1Gi"
      }
    }
  }
}

resource "kubernetes_manifest" "f2-control-db" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Database"
    "metadata" = {
      "name"      = local.f2-control-plane-db-name
      "namespace" = var.namespace
    }
    "spec" = {
      "cluster" = {
        "name" = kubernetes_manifest.f2-cluster.object.metadata.name
      }
      "allowConnections" = true
      "name"             = local.f2-control-plane-db-name
      "owner"            = kubernetes_secret_v1.f2-db-admin.data.username
      "schemas" = [
        {
          "name"  = local.f2-analytics-db-namespace
          "owner" = kubernetes_secret_v1.f2-analytics-db.data.username
        },
        {
          "name"  = local.f2-auth-db-namespace
          "owner" = kubernetes_secret_v1.f2-auth-config.data.username
        },
        {
          "name"  = local.f2-realtime-db-namespace
          "owner" = kubernetes_secret_v1.f2-realtime-db.data.username
        }
      ]
    }
  }
}

resource "kubernetes_secret_v1" "f2-bootstrap" {
  metadata {
    name      = "f2-bootstrap-${var.environment}"
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

resource "kubernetes_secret_v1" "f2-db-admin" {
  metadata {
    name      = "f2-admin-${var.environment}"
    namespace = var.namespace
  }

  data = {
    password = random_password.f2-bootstrap.result
    username = "admin"
  }

  type = "kubernetes.io/basic-auth"
}

resource "random_password" "f2-db-admin" {
  length  = 16
  special = true
}
