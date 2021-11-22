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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6.0"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_project" "do-k8s-2021" {
  name        = "do-k8s-2021"
  description = "DigitalOcean Kubernetes Challenge 2021"
  purpose     = "Deploy a security and compliance system"
  resources = [
    "do:kubernetes:${digitalocean_kubernetes_cluster.doks.id}" # this is a bit tedious
  ]
}

resource "digitalocean_vpc" "do-k8s-2021" {
  name   = "do-k8s-2021"
  region = "sgp1"
}

data "digitalocean_kubernetes_versions" "doks" {
  version_prefix = "1.21."
}

resource "digitalocean_kubernetes_cluster" "doks" {
  name         = "do-k8s-2021"
  region       = "sgp1"
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.doks.latest_version

  vpc_uuid = digitalocean_vpc.do-k8s-2021.id

  maintenance_policy {
    start_time = "16:00"
    day        = "friday"
  }

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-1vcpu-2gb" # 1 cpu, 2gb ram (1gb useable)
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3 # this is the maximum allowed nodes on my new account without requesting an increase
  }
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.doks.kube_config[0].host
  token                  = digitalocean_kubernetes_cluster.doks.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.doks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
  host                   = digitalocean_kubernetes_cluster.doks.kube_config[0].host
  token                  = digitalocean_kubernetes_cluster.doks.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.doks.kube_config[0].cluster_ca_certificate)
  }
}
