
module "core_services" {
  source      = "../../terraform-modules/gcp-gke-core-services"
  md_metadata = var.md_metadata
  logging = {
    opensearch = {
      enabled             = var.observability.logging.destination == "opensearch"
      persistence_size_gi = try(var.observability.logging.opensearch.persistence_size, 10)
      retention_days      = try(var.observability.logging.opensearch.retention_days, 7)
    }
  }
  vpc_grn                       = var.subnetwork.data.infrastructure.gcp_global_network_grn
  gcp_project_id                = var.gcp_authentication.data.project_id
  gcp_region                    = var.subnetwork.specs.gcp.region
  cloud_dns_managed_zones       = var.core_services.cloud_dns_managed_zones
  control_plane_ipv4_cidr_block = var.cluster_networking.master_ipv4_cidr_block
}
