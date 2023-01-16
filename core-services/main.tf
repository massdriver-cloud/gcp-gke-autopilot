module "core_services" {
  source                      = "github.com/massdriver-cloud/terraform-modules//gcp-gke-core-services?ref=f3f8ff8"
  md_metadata                 = var.md_metadata
  kubernetes_cluster_artifact = local.kubernetes_cluster_artifact
  enable_ingress              = var.core_services.enable_ingress
  cloud_dns_managed_zones     = var.core_services.cloud_dns_managed_zones

  gcp_config = {
    project_id = var.gcp_authentication.data.project_id
    region     = var.subnetwork.specs.gcp.region
  }
}
