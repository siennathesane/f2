variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "gamma", "prod"], var.environment)
    error_message = "Environment must be dev, gamma, or prod."
  }
}

variable "dockerconfigjson" {
  description = "Used in your local development cluster to pull Github container images"
  type        = string
}

locals {
  public-url  = var.environment == "dev" ? "localhost:8080" : var.environment == "prod" ? "api.f2.pub" : "api.${var.environment}.f2.pub"
  public-fqdn = var.environment == "dev" ? "localhost" : var.environment == "prod" ? "api.f2.pub" : "api.${var.environment}.f2.pub"
}
