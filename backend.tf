terraform {
 backend "gcs" {
   bucket = "stacktome-prod"
   path = "/jenkins/"
 }
}

provider "google" {
  project = "stacktome-prod"
  region = "europe-west1"
  version = "~> 1.5"
}