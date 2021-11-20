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

resource "digitalocean_project" "do-k8s-2021" {
  name        = "do-k8s-2021"
  description = "DigitalOcean Kubernetes Challenge 2021"
  purpose     = "Deploy a security and compliance system"
}
