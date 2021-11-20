terraform {
  backend "remote" {
    organization = "ljones"

    workspaces {
      name = "do-k8s-2021"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.16.0"
    }
  }
}

provider "digitalocean" {}
