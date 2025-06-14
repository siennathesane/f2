resource "kubernetes_secret_v1" "f2-auth-jwt" {
  metadata {
    name      = "f2-auth-jwt-${var.environment}"
    namespace = var.namespace
  }

  data = {
    anonKey    = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzQ5ODU1NjAwLCJleHAiOjE5MDc2MjIwMDB9.al_97DVvYPKyo90OlBiAXkzMO_N92hKGJZ14j91-U8Y"
    secret     = "LkCkQDC5S2oyPs7IgqWi0dvDWAntDhdKRLx0es/C"
    serviceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UiLCJpYXQiOjE3NDk4NTU2MDAsImV4cCI6MTkwNzYyMjAwMH0.k7pMOJPCc41ZDHrb1lGS6eQuTWaZWiDttdanbY1y-JY"
    expiry     = "3600"
  }

  type = "Opaque"
}
