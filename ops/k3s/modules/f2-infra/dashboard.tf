resource "kubernetes_secret_v1" "f2-dashboard-creds" {
  metadata {
    name      = "f2-dashboard-creds"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" = "true"
    }
  }

  data = {
    username = "dashboard"
    password = random_password.f2-dashboard-password.result
  }

  type = "Opaque"
}

resource "random_password" "f2-dashboard-password" {
  length  = 16
  special = false
}
