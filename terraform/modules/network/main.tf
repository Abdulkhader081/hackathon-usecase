resource "google_compute_network" "vpc" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "${var.project}-subnet-a"
  ip_cidr_range = "10.10.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "${var.project}-subnet-b"
  ip_cidr_range = "10.10.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}
