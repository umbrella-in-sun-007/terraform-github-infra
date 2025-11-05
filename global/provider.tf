# Global Provider Configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.default_region
  zone    = var.default_zone

  default_labels = var.default_labels
}

provider "google-beta" {
  project = var.project_id
  region  = var.default_region
  zone    = var.default_zone

  default_labels = var.default_labels
}
