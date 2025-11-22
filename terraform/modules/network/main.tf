resource "google_compute_network" "vpc" {
  name = "${var.project}-vpc"
  auto_create_subnetworks = false 
}
resource "google_compute_subnetwork" "public" {
  count = 2
  name = "${var.project}-public-${count.index}"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 4 , count.index)
  region = var.region
  network = google_compute_network.vpc.id 
}
resource "
  
