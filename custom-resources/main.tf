module "custom_resources" {
  source                  = "github.com/massdriver-cloud/terraform-modules//gcp-gke-custom-resources?ref=1b37297"
  cloud_dns_managed_zones = var.core_services.cloud_dns_managed_zones

  gcp_config = {
    project_id = var.gcp_authentication.data.project_id
  }
}
