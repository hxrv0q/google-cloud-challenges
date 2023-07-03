provider "google" {
  project = "PROJECT_ID"
  region  = "us-central1"
}

resource "google_container_cluster" "hello_cluster" {
  name     = "hello-cluster"
  location = "us-central1-a"

  initial_node_count = 3
  min_master_version = "1.25.5-gke.2000"

  release_channel {
    channel = "REGULAR"
  }

  node_config {
    oauth_scopes = [ 
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",   
     ]
  }

  cluster_autoscaling {
    enabled = true

    resource_limits {
      minimum = 2
      maximum = 6
      resource_type = "cpu"
    }
  }
}

resource "kubernetes_namespace" "prod_namespace" {
  metadata {
    name = "prod"
  } 
}

resource "kubernetes_namespace" "dev_namespace" {
  metadata {
    name = "dev"
  } 
}