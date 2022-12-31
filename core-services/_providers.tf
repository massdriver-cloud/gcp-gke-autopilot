

terraform {
  required_version = ">= 1.0"
  required_providers {
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 1.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

data "google_client_config" "provider" {}

data "google_container_cluster" "cluster" {
  name     = local.cluster_name
  location = var.subnetwork.specs.gcp.region
}

locals {
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  cluster_token          = data.google_client_config.provider.access_token
  cluster_host           = "https://${data.google_container_cluster.cluster.endpoint}"
  cluster_name           = var.md_metadata.name_prefix
  cluster_network_tag    = "gke-${local.cluster_name}"
}

provider "google" {
  project     = var.gcp_authentication.data.project_id
  credentials = jsonencode(var.gcp_authentication.data)
  region      = var.subnetwork.specs.gcp.region
}

provider "google-beta" {
  project     = var.gcp_authentication.data.project_id
  credentials = jsonencode(var.gcp_authentication.data)
  region      = var.subnetwork.specs.gcp.region
}

provider "kubernetes" {
  host                   = local.cluster_host
  token                  = local.cluster_token
  cluster_ca_certificate = local.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_host
    token                  = local.cluster_token
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}
