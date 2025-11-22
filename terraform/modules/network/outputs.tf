output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnet_a_id" {
  value = google_compute_subnetwork.subnet_a.id
}

output "subnet_b_id" {
  value = google_compute_subnetwork.subnet_b.id
}
