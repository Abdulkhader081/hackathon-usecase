# GKE Node Pool Service Account ("default compute SA")
data "google_compute_default_service_account" "gke" {}

# Create a Service Account for each microservice
resource "google_service_account" "sa" {
  for_each = toset(var.services)
  account_id   = "${each.key}-sa"
  display_name = "${each.key} service account"
}

# Allow microservices to pull images from GCR
resource "google_project_iam_member" "puller" {
  for_each = google_service_account.sa

  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${each.value.email}"
}

# Allow GKE nodes to pull from GCR (node SA → objectViewer)
resource "google_project_iam_member" "gke_nodes" {
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_compute_default_service_account.gke.email}"
}

