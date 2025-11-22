############################################
# VPC
############################################
resource "google_compute_network" "vpc" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

############################################
# SUBNETS (2 AZs)
############################################
resource "google_compute_subnetwork" "subnet_a" {
  name          = "${var.project}-subnet-a"
  ip_cidr_range = "10.10.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "${var.project}-subnet-b"
  ip_cidr_range = "10.10.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

############################################
# CLOUD ROUTER (required for NAT)
############################################
resource "google_compute_router" "router" {
  name    = "${var.project}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

############################################
# CLOUD NAT (Outbound internet access)
############################################
resource "google_compute_router_nat" "nat" {
  name                               = "${var.project}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

############################################
# FIREWALL RULES (Security Groups Equivalent)
############################################

# Allow internal communication in VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project}-allow-internal"
  network = google_compute_network.vpc.id

  allows {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

# Allow SSH (Optional – restrict using var.ssh_source_ranges)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project}-allow-ssh"
  network = google_compute_network.vpc.id

  allows {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
}

# Microservices: exposing ports 3001/3002/8080 (example)
resource "google_compute_firewall" "microservices_ingress" {
  name    = "${var.project}-microservices-ingress"
  network = google_compute_network.vpc.id

  allows {
    protocol = "tcp"
    ports    = var.microservice_ports
  }

  source_ranges = var.microservice_source_ranges
}

############################################
# DEFAULT OUTBOUND INTERNET ROUTE
# (Internet Gateway in GCP)
############################################
resource "google_compute_route" "default_internet_route" {
  name                   = "${var.project}-default-route"
  network                = google_compute_network.vpc.id
  destination_range      = "0.0.0.0/0"
  next_hop_internet      = true
  priority               = 1000
}
