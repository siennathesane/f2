terraform {
  required_providers {

    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.lima/k3s/copied-from-guest/kubeconfig.yaml"
  }
}

provider "kubernetes" {
  config_path = "~/.lima/k3s/copied-from-guest/kubeconfig.yaml"
}
