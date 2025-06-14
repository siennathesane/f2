variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "gamma", "prod"], var.environment)
    error_message = "Environment must be dev, gamma, or prod."
  }
}

locals {
  public-url = var.environment == "prod" ? "api.f2.pub" : "api.${var.environment}.f2.pub"
  # public-realtime-url = "realtime.${local.public-url}"
}
