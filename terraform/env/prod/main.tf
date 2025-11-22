
terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# ---------------- NETWORK ----------------
module "network" {
  source  = "../../modules/network"
  project = var.project
  region  = var.region
}

# ---------------- GKE ----------------
module "gke" {
  source     = "../../modules/gke"
  project    = var.project
  region     = var.region
  network_id = module.network.network_id
}

# -------- K8s Provider Auth from GKE --------
data "google_container_cluster" "gke" {
  name     = module.gke.cluster_name
  location = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

# ---------------- MICROSERVICES ----------------
module "application_service" {
  source                   = "../../modules/microservice"
  name                     = "application-service"
  image_repository         = "gcr.io/${var.project}/application-service"
  image_tag                = var.image_tag_application
  cluster_endpoint         = data.google_container_cluster.gke.endpoint
  cluster_token            = data.google_client_config.default.access_token
  client_certificate       = ""
  client_key               = ""
  cluster_ca_certificate   = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

module "order_service" {
  source                   = "../../modules/microservice"
  name                     = "order-service"
  image_repository         = "gcr.io/${var.project}/order-service"
  image_tag                = var.image_tag_order
  cluster_endpoint         = data.google_container_cluster.gke.endpoint
  cluster_token            = data.google_client_config.default.access_token
  client_certificate       = ""
  client_key               = ""
  cluster_ca_certificate   = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

module "patient_service" {
  source                   = "../../modules/microservice"
  name                     = "patient-service"
  image_repository         = "gcr.io/${var.project}/patient-service"
  image_tag                = var.image_tag_patient
  cluster_endpoint         = data.google_container_cluster.gke.endpoint
  cluster_token            = data.google_client_config.default.access_token
  client_certificate       = ""
  client_key               = ""
  cluster_ca_certificate   = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

