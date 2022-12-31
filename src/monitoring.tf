# Experimenting with alarms for GKE
# This has only been loosely tested

locals {
  automated_alarms = {
    restart_count = {
      metric_type        = "kubernetes.io/container/restart_count"
      resource_type      = "k8s_container"
      threshold          = 5
      alignment_period_s = 60
      duration_s         = 60
    }
  }

  # alarms_map = {
  #   "AUTOMATED" = local.automated_alarms
  #   "DISABLED"  = {}
  #   "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  # }
  # alarms = lookup(local.alarms_map, var.monitoring.mode, {})
  alarms = local.automated_alarms
}

module "alarm_channel" {
  source      = "github.com/massdriver-cloud/terraform-modules//gcp-alarm-channel?ref=bfcf556"
  md_metadata = var.md_metadata
}

module "restart_count" {
  source                  = "github.com/massdriver-cloud/terraform-modules//gcp-metric-alarm"
  notification_channel_id = module.alarm_channel.id
  cloud_resource_id       = google_container_cluster.cluster.id
  md_metadata             = var.md_metadata
  display_name            = "Container Restart Count"
  message                 = "High container restart counts might indicate containers are crashing."
  alarm_configuration     = local.alarms.restart_count
}
