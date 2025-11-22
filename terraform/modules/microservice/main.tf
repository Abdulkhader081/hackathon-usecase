provider "kubernetes" {
  host                   = var.cluster_endpoint
  token                  = var.cluster_token
  client_certificate     = var.client_certificate
  client_key             = var.client_key
  cluster_ca_certificate = var.cluster_ca_certificate
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.name
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name      = "${var.name}-sa"
    namespace = var.name
  }
}

resource "helm_release" "service" {
  name       = var.name
  chart      = "${path.root}/../../charts/${var.name}"
  namespace  = var.name

  set {
    name  = "image.repository"
    value = var.image_repository
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }
}
