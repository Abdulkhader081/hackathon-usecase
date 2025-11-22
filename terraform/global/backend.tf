terraform {
  required_version = ">=1.4"
  backend "gcs" {
    bucket = "my-tf-state-bucket"
    prefix = "terraform/state"
  }
}
