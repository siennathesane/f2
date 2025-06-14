variable "environment" {
  type = string
}

variable "namespace" {
  type = string
}

variable "ghcr-pull-secret-name" {
  type = string
}

variable "public-url" {
  type = string
}

variable "public-fqdn" {
  type = string
}

# variable "public-realtime-url" {
#   type = string
# }

variable "goauth-version" {
  type    = string
  default = "v2.175.0"
}

variable "logflare-version" {
  type    = string
  default = "1.11.0"
}
