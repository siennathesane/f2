resource "kubernetes_secret_v1" "f2-auth-jwt" {
  metadata {
    name      = "f2-auth-jwt-${var.environment}"
    namespace = var.namespace
  }

  data = {
    anonKey    = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzQ5MzM3MjAwLCJleHAiOjE5MDcxMDM2MDB9.2AQ0gHTLBTk1UlnyxSX30FShwURuJ0jCd1VR8cX6-Wk"
    secret     = "LkCkQDC5S2oyPs7IgqWi0dvDWAntDhdKRLx0es/COd5NJsPQWjrdepaJxx4jDT50oziIrOKjhCsizuJqhxseQQ=="
    serviceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UiLCJpYXQiOjE3NDkzMzcyMDAsImV4cCI6MTkwNzEwMzYwMH0.KmD-pZEY3sBAKAa067qjPH1S51ciu26EvEpcer5zQrE"
  }

  type = "Opaque"
}
