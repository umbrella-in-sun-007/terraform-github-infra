# Global Variables

variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "default_region" {
  description = "Default region for resources"
  type        = string
  default     = "us-central1"
}

variable "default_zone" {
  description = "Default zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

variable "organization_id" {
  description = "The organization ID (optional)"
  type        = string
  default     = null
}

variable "billing_account" {
  description = "The billing account ID"
  type        = string
  default     = null
}

variable "default_labels" {
  description = "Default labels to apply to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    project    = "my-project"
  }
}

variable "vpc_cidr" {
  description = "Default CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_apis" {
  description = "List of APIs to enable"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "cloudsql.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

variable "environments" {
  description = "Map of environment configurations"
  type = map(object({
    region           = string
    zone             = string
    machine_type     = string
    min_instances    = number
    max_instances    = number
    enable_apis      = list(string)
    preemptible_vms  = bool
  }))
  default = {
    dev = {
      region          = "us-central1"
      zone            = "us-central1-a"
      machine_type    = "e2-micro"
      min_instances   = 1
      max_instances   = 3
      enable_apis     = ["compute.googleapis.com", "storage.googleapis.com"]
      preemptible_vms = true
    }
    staging = {
      region          = "us-central1"
      zone            = "us-central1-b"
      machine_type    = "e2-small"
      min_instances   = 2
      max_instances   = 5
      enable_apis     = ["compute.googleapis.com", "storage.googleapis.com", "container.googleapis.com"]
      preemptible_vms = false
    }
    prod = {
      region          = "us-east1"
      zone            = "us-east1-a"
      machine_type    = "e2-standard-2"
      min_instances   = 3
      max_instances   = 10
      enable_apis     = ["compute.googleapis.com", "storage.googleapis.com", "container.googleapis.com", "cloudsql.googleapis.com"]
      preemptible_vms = false
    }
  }
}
