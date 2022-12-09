locals {
  latest_master_version = data.google_container_engine_versions.versions_in_region.latest_master_version
  latest_node_version   = data.google_container_engine_versions.versions_in_region.latest_node_version

  cluster_name        = var.md_metadata.name_prefix
  cluster_network_tag = "gke-${local.cluster_name}"
}

# data "google_compute_network" "main" {
#   name = "default-us-east1"
# }

# data "google_compute_subnetwork" "lookup" {
#   for_each = toset(data.google_compute_network.main.subnetworks_self_links)
#   name   = "default-us-east1"
#   region = "us-east1"
# }

# resource "utility_available_cidr" "cidr" {
#   from_cidrs = data.google_compute_network.main.gateway_ipv4
#   used_cidrs = flatten([for subnet in data.google_compute_subnetwork.lookup : subnet.gateway_address])
#   mask       = 16
# }

# This gives us the latest version available in the current region
# that matches the version prefix: [1.21., 1.22., etc..]
data "google_container_engine_versions" "versions_in_region" {
  provider       = google-beta
  location       = var.subnetwork.specs.gcp.region
  version_prefix = "${var.k8s_version}."
  depends_on = [
    module.apis
  ]
}

// https://github.com/terraform-google-modules/terraform-google-kubernetes-engine
resource "google_container_cluster" "cluster" {
  provider           = google-beta
  name               = local.cluster_name
  resource_labels    = var.md_metadata.default_tags
  location           = var.subnetwork.specs.gcp.region
  min_master_version = local.latest_master_version
  enable_autopilot   = true

  node_config {
    labels = var.md_metadata.default_tags
    # Conditionally allow or deny requests based on the tag.
    tags = [local.cluster_network_tag]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  # NETWORKING
  network         = var.subnetwork.data.infrastructure.gcp_global_network_grn
  subnetwork      = var.subnetwork.data.infrastructure.grn
  networking_mode = "VPC_NATIVE"

  //

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
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
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

  lifecycle {
    ignore_changes = [resource_labels["asmv"], resource_labels["mesh_id"]]
  }

  depends_on = [
    module.apis
  ]
}
