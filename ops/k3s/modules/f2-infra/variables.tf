variable "environment" {
  type    = string
}

variable "namespace" {
  type    = string
}

variable "ghcr-pull-secret-name" {
  type    = string
}

variable "public-url" {
  type    = string
}

variable "goauth-version" {
  type    = string
  default = "v2.175.0"
}
