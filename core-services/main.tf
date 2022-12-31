module "core_services" {
  # source                      = "github.com/massdriver-cloud/terraform-modules//gcp-gke-core-services?ref=8d71513"
  source                      = "../../../terraform-modules/gcp-gke-core-services"
  md_metadata                 = var.md_metadata
  kubernetes_cluster_artifact = local.kubernetes_cluster_artifact
  enable_ingress              = var.core_services.enable_ingress
  cloud_dns_managed_zones     = var.core_services.cloud_dns_managed_zones

  logging = {
    opensearch = {
      enabled             = var.observability.logging.destination == "opensearch"
      persistence_size_gi = try(var.observability.logging.opensearch.persistence_size, 10)
      retention_days      = try(var.observability.logging.opensearch.retention_days, 7)
    }
  }

  gcp_config = {
    project_id = var.gcp_authentication.data.project_id
    region     = var.subnetwork.specs.gcp.region
  }
}
