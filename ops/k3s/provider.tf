terraform {
  required_providers {

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.lima/k3s/copied-from-guest/kubeconfig.yaml"
}

provider "kubectl" {
  config_path = "~/.lima/k3s/copied-from-guest/kubeconfig.yaml"
}
