/******************************************
  Webhooks/Admission Controllers deployed to the GKE cluster,
  get called from the control plane. If the cluster has private _nodes_
  and if a webhook, etc.. get deployed to those nodes, this firewall rule is needed.
  Without this, things like cert-manager (double check) won't work
  https://github.com/kubernetes/kubernetes/issues/79739
 *****************************************/
resource "google_compute_firewall" "control_plane_ingress" {
  name        = "${var.md_metadata.name_prefix}-webhook"
  description = "Allow GKE control plane to hit pods for admission controllers/webhooks"
  project     = var.gcp_authentication.data.project_id
  network     = var.subnetwork.data.infrastructure.gcp_global_network_grn
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = [var.cluster_networking.master_ipv4_cidr_block]
  source_tags   = []
  target_tags   = [local.cluster_network_tag]

  allow {
    protocol = "tcp"
    ports    = [8443]
  }
}
