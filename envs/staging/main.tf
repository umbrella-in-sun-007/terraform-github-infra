# Staging Environment Configuration
# This file orchestrates all modules for the staging environment

# Local values for this environment
locals {
  environment = "staging"
  name_prefix = "${var.project_name}-${local.environment}"
  
  common_labels = {
    environment = local.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}

# Network Module
module "network" {
  source = "../../modules/network"
  
  name_prefix  = local.name_prefix
  environment  = local.environment
  region       = var.region
  
  # Staging-specific network configuration
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway      = var.enable_nat_gateway
  enable_secondary_ranges = var.enable_gke_ranges # Enable for GKE learning
  
  pod_ip_ranges     = var.pod_ip_ranges
  service_ip_ranges = var.service_ip_ranges
  
  common_tags = local.common_labels
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  project_id = var.project_id
  
  # Staging service accounts
  service_accounts = {
    "staging-compute-sa" = {
      display_name = "Staging Compute Service Account"
      description  = "Service account for compute instances in staging environment"
    }
    "staging-gke-sa" = {
      display_name = "Staging GKE Service Account"
      description  = "Service account for GKE workloads in staging environment"
    }
    "staging-storage-sa" = {
      display_name = "Staging Storage Service Account"
      description  = "Service account for storage operations in staging environment"
    }
  }
  
  # Project-level IAM bindings for staging
  project_iam_bindings = {
    "roles/compute.instanceAdmin.v1" = [
      "serviceAccount:${module.iam.service_account_emails["staging-compute-sa"]}"
    ]
    "roles/container.nodeServiceAccount" = [
      "serviceAccount:${module.iam.service_account_emails["staging-gke-sa"]}"
    ]
    "roles/storage.objectAdmin" = [
      "serviceAccount:${module.iam.service_account_emails["staging-storage-sa"]}"
    ]
  }
}

# Compute Module
module "compute" {
  source = "../../modules/compute"
  
  name_prefix         = local.name_prefix
  environment         = local.environment
  project_id          = var.project_id
  region              = var.region
  
  network_self_link   = module.network.network_self_link
  subnet_self_link    = module.network.private_subnet_ids[0] # Use private subnet
  
  # Staging-specific compute configuration
  machine_type        = var.machine_type
  create_single_vm    = false  # No single VM for staging
  assign_public_ip    = false  # Private instances only
  preemptible         = false  # More stable for staging
  
  # Instance group configuration
  create_instance_group = true
  enable_autoscaling    = var.enable_autoscaling
  target_size          = var.target_size
  min_replicas         = var.min_replicas
  max_replicas         = var.max_replicas
  
  network_tags = ["staging-vm", "allow-iap-ssh", "allow-health-check"]
  
  startup_script = var.startup_script
}

# Storage Module
module "storage" {
  source = "../../modules/storage"
  
  project_id     = var.project_id
  common_labels  = local.common_labels
  
  # Staging storage buckets
  storage_buckets = {
    "${local.name_prefix}-app-data" = {
      location                     = var.region
      storage_class               = "STANDARD"
      force_destroy               = false # Protect staging data
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = true
      labels                      = { purpose = "app-data", tier = "staging" }
      lifecycle_rules = [
        {
          action = {
            type          = "SetStorageClass"
            storage_class = "NEARLINE"
          }
          condition = {
            age = 30
          }
        }
      ]
      cors_rules       = []
      website_config   = null
      retention_policy = null
      logging_config   = null
      kms_key_name    = null
    }
    "${local.name_prefix}-backups" = {
      location                     = var.region
      storage_class               = "NEARLINE"
      force_destroy               = false
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = true
      labels                      = { purpose = "backups", tier = "staging" }
      lifecycle_rules = [
        {
          action = {
            type = "Delete"
          }
          condition = {
            age = 90 # Longer retention for staging
          }
        }
      ]
      cors_rules       = []
      website_config   = null
      retention_policy = null
      logging_config   = null
      kms_key_name    = null
    }
    "${local.name_prefix}-static-assets" = {
      location                     = "US"
      storage_class               = "STANDARD"
      force_destroy               = false
      uniform_bucket_level_access = true
      public_access_prevention    = "inherited"
      versioning_enabled          = false
      labels                      = { purpose = "static-assets", tier = "staging" }
      lifecycle_rules             = []
      cors_rules = [
        {
          origin  = ["*"]
          method  = ["GET", "HEAD"]
          response_header = ["Content-Type"]
          max_age_seconds = 3600
        }
      ]
      website_config = {
        main_page_suffix = "index.html"
        not_found_page   = "404.html"
      }
      retention_policy = null
      logging_config   = null
      kms_key_name    = null
    }
  }
}
