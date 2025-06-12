locals {
  f2-control-plane-db-name = "f2controldb${var.environment}"
}

resource "kubectl_manifest" "f2-image-catalog" {
  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ImageCatalog"
    metadata = {
      name      = "postgresql"
      namespace = var.namespace
    }
    spec = {
      images = [
        {
          major = 15
          image = "ghcr.io/cloudnative-pg/postgresql:15.6"
        },
        {
          major = 16
          image = "ghcr.io/cloudnative-pg/postgresql:16.8"
        },
        {
          major = 17
          image = "ghcr.io/cloudnative-pg/postgresql:17.5"
        }
      ]
    }
  })
}

resource "kubectl_manifest" "f2-cluster" {
  depends_on = [
    kubernetes_secret_v1.f2-bootstrap,
    kubernetes_secret_v1.f2-db-admin,
    kubernetes_secret_v1.f2-auth-config,
    kubernetes_secret_v1.f2-analytics-db,
    kubernetes_secret_v1.f2-realtime-db,
    kubernetes_secret_v1.f2-postgrest-creds,
    kubectl_manifest.f2-image-catalog
  ]
  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "f2-postgres-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      enableSuperuserAccess = true
      superuserSecret = {
        name = kubernetes_secret_v1.f2-db-admin.metadata[0].name
      }
      imageCatalogRef = {
        apiGroup = "postgresql.cnpg.io"
        kind     = "ImageCatalog"
        name     = "postgresql"
        major    = 17
      }
      bootstrap = {
        initdb = {
          database = "bootstrap"
          owner    = kubernetes_secret_v1.f2-bootstrap.data.username
          secret = {
            name = kubernetes_secret_v1.f2-bootstrap.metadata[0].name
          }
        }
      }
      managed = {
        roles = [
          {
            name      = kubernetes_secret_v1.f2-auth-config.data.username
            ensure    = "present"
            login     = true
            superuser = false
            passwordSecret = {
              name = kubernetes_secret_v1.f2-auth-config.metadata[0].name
            }
          },
          {
            name      = kubernetes_secret_v1.f2-analytics-db.data.username
            ensure    = "present"
            login     = true
            superuser = true # todo(siennathesane): this is a blaring security hole
            passwordSecret = {
              name = kubernetes_secret_v1.f2-analytics-db.metadata[0].name
            }
          },
          {
            name      = kubernetes_secret_v1.f2-realtime-db.data.username
            ensure    = "present"
            login     = true
            superuser = false
            passwordSecret = {
              name = kubernetes_secret_v1.f2-realtime-db.metadata[0].name
            }
          },
          {
            name      = kubernetes_secret_v1.f2-postgrest-creds.data.username
            ensure    = "present"
            login     = true
            superuser = false
            passwordSecret = {
              name = kubernetes_secret_v1.f2-postgrest-creds.metadata[0].name
            }
          },
          {
            name      = kubernetes_secret_v1.f2-postgrest-creds.data.anon_username
            ensure    = "present"
            login     = false
            superuser = false
          },
          {
            name      = kubernetes_secret_v1.f2-postgrest-creds.data.web_username
            ensure    = "present"
            login     = false
            superuser = false
          },
        ]
      }
      instances = 1
      storage = {
        size = "1Gi"
      }
    }
  })
}

resource "kubectl_manifest" "f2-control-db" {
  depends_on = [kubectl_manifest.f2-cluster]
  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "f2-control-plane-db-${var.environment}"
      namespace = var.namespace
    }
    spec = {
      cluster = {
        name = kubectl_manifest.f2-cluster.name
      }
      allowConnections = true
      name             = local.f2-control-plane-db-name
      owner            = kubernetes_secret_v1.f2-db-admin.data.username
      schemas = [
        {
          name  = local.f2-analytics-db-namespace
          owner = kubernetes_secret_v1.f2-analytics-db.data.username
        },
        {
          name  = local.f2-auth-db-namespace
          owner = kubernetes_secret_v1.f2-auth-config.data.username
        },
        {
          name  = local.f2-realtime-db-namespace
          owner = kubernetes_secret_v1.f2-realtime-db.data.username
        }
      ]
    }
  })
}

resource "kubernetes_secret_v1" "f2-bootstrap" {
  metadata {
    name      = "f2-bootstrap-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    password = random_password.f2-bootstrap.result
    username = "bootstrap"
  }

  type = "kubernetes.io/basic-auth"
}

resource "random_password" "f2-bootstrap" {
  length  = 16
  special = false
}

resource "kubernetes_secret_v1" "f2-db-admin" {
  metadata {
    name      = "f2-admin-${var.environment}"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    password = random_password.f2-db-admin.result
    username = "postgres"
  }

  type = "kubernetes.io/basic-auth"
}

resource "random_password" "f2-db-admin" {
  length  = 16
  special = false
}
