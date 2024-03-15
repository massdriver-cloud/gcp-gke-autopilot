locals {
  cluster_name        = var.md_metadata.name_prefix
  cluster_network_tag = "gke-${local.cluster_name}"
}

// https://github.com/terraform-google-modules/terraform-google-kubernetes-engine
resource "google_container_cluster" "cluster" {
  provider           = google-beta
  name               = local.cluster_name
  resource_labels    = var.md_metadata.default_tags
  location           = var.subnetwork.specs.gcp.region
  enable_autopilot   = true

  release_channel {
    channel = "STABLE"
  }

  # NETWORKING
  network         = var.subnetwork.data.infrastructure.gcp_global_network_grn
  subnetwork      = var.subnetwork.data.infrastructure.grn
  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_networking.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.cluster_networking.services_ipv4_cidr_block
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.cluster_networking.master_ipv4_cidr_block
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # CLUSTER ADD-ONS
  addons_config {
    http_load_balancing {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  # add network tags so firewall rules can be set for
  # admision controller webhooks, etc.
  node_pool_auto_config {
    network_tags {
      tags = [local.cluster_network_tag]
    }
  }

  lifecycle {
    ignore_changes = [resource_labels["asmv"], resource_labels["mesh_id"]]
  }

  depends_on = [
    module.apis
  ]
}
