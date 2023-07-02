provider "google" {
  credentials = file("account.json")
  project     = "qwiklabs-gcp-00-254afd61eee5"
  region      = "us-east1"
  zone        = "us-east1-b"
}

locals {
  bucket_id   = "memories-bucket-51010"
  topic_id    = "memories-topic-633"
  function_id = "memories-thumbnail-generator"

  project = "qwiklabs-gcp-00-254afd61eee5"
  student = "student-01-81aba7a82174@qwiklabs.net"
}

resource "google_storage_bucket" "photography_bucket" {
  name          = local.bucket_id
  location      = "us-east1"
  storage_class = "STANDARD"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_pubsub_topic" "photography_topic" {
  name = local.topic_id
}

resource "null_resource" "replace_topic_id" {
  provisioner "local-exec" {
    command = <<EOF
      cp index.js function/index.js
      sed -i 's/REPLACE_WITH_YOUR_TOPIC_ID/${local.topic_id}/g' function/index.js
    EOF
  }
}


data "archive_file" "function_code" {
  type        = "zip"
  source_dir  = "./function"
  output_path = "thumbnail.zip"
}

output "function_url" {
  value = google_cloudfunctions_function.thumbnail_generator.https_trigger_url
}

resource "google_cloudfunctions_function" "thumbnail_generator" {
  name         = local.function_id
  runtime      = "nodejs14"
  entry_point  = "thumbnail"

  source_archive_bucket = google_storage_bucket.photography_bucket.name
  source_archive_object = "thumbnail.zip"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource = google_storage_bucket.photography_bucket.name
  }

  ingress_settings = "ALLOW_INTERNAL_ONLY"
}
