terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name = var.project_id
  location    = var.location
  uniform_bucket_level_access = true
  force_destroy = true
}