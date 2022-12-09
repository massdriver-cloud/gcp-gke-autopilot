resource "google_service_account" "nodes" {
  project      = var.gcp_authentication.data.project_id
  account_id   = "${substr(var.md_metadata.name_prefix, 0, 24)}-nodes"
  display_name = "Service Account for ${var.md_metadata.name_prefix} nodes"

  depends_on = [
    module.apis
  ]
}

resource "google_project_iam_member" "nodes_service_account-log_writer" {
  project = google_service_account.nodes.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_service_account-metric_writer" {
  project = google_service_account.nodes.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_service_account-monitoring_viewer" {
  project = google_service_account.nodes.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_service_account-resourceMetadata-writer" {
  project = google_service_account.nodes.project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_service_account-gcr" {
  project = google_service_account.nodes.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_service_account-artifact-registry" {
  project = google_service_account.nodes.project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}
