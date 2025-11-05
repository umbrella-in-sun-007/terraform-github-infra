# Production Environment Configuration
# This file orchestrates all modules for the production environment

# Local values for this environment
locals {
  environment = "prod"
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
  
  # Production-specific network configuration
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway      = var.enable_nat_gateway
  enable_secondary_ranges = var.enable_gke_ranges
  
  pod_ip_ranges     = var.pod_ip_ranges
  service_ip_ranges = var.service_ip_ranges
  
  common_tags = local.common_labels
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  project_id = var.project_id
  
  # Production service accounts with principle of least privilege
  service_accounts = {
    "prod-compute-sa" = {
      display_name = "Production Compute Service Account"
      description  = "Service account for compute instances in production environment"
    }
    "prod-gke-sa" = {
      display_name = "Production GKE Service Account"
      description  = "Service account for GKE workloads in production environment"
    }
    "prod-storage-sa" = {
      display_name = "Production Storage Service Account"
      description  = "Service account for storage operations in production environment"
    }
    "prod-monitoring-sa" = {
      display_name = "Production Monitoring Service Account"
      description  = "Service account for monitoring and logging in production"
    }
  }
  
  # Project-level IAM bindings for production
  project_iam_bindings = {
    "roles/compute.instanceAdmin.v1" = [
      "serviceAccount:${module.iam.service_account_emails["prod-compute-sa"]}"
    ]
    "roles/container.nodeServiceAccount" = [
      "serviceAccount:${module.iam.service_account_emails["prod-gke-sa"]}"
    ]
    "roles/storage.objectAdmin" = [
      "serviceAccount:${module.iam.service_account_emails["prod-storage-sa"]}"
    ]
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${module.iam.service_account_emails["prod-monitoring-sa"]}"
    ]
    "roles/logging.logWriter" = [
      "serviceAccount:${module.iam.service_account_emails["prod-monitoring-sa"]}"
    ]
  }
  
  # Enable audit logging for production
  enable_audit_logging = true
}

# Compute Module
module "compute" {
  source = "../../modules/compute"
  
  name_prefix         = local.name_prefix
  environment         = local.environment
  project_id          = var.project_id
  region              = var.region
  
  network_self_link   = module.network.network_self_link
  subnet_self_link    = module.network.private_subnet_ids[0] # Private subnet only
  
  # Production-specific compute configuration
  machine_type        = var.machine_type
  create_single_vm    = false  # No single VMs in production
  assign_public_ip    = false  # Private instances only
  preemptible         = false  # High availability required
  enable_shielded_vm  = true   # Enhanced security
  
  # Instance group configuration
  create_instance_group = true
  enable_autoscaling    = var.enable_autoscaling
  target_size          = var.target_size
  min_replicas         = var.min_replicas
  max_replicas         = var.max_replicas
  
  # Production-specific settings
  auto_healing_delay = 60  # Faster healing
  cpu_utilization_target = 0.5  # Conservative scaling
  
  network_tags = ["prod-vm", "allow-iap-ssh", "allow-health-check"]
  
  startup_script = var.startup_script
}

# Storage Module
module "storage" {
  source = "../../modules/storage"
  
  project_id     = var.project_id
  common_labels  = local.common_labels
  
  # Production storage buckets with enhanced security and retention
  storage_buckets = {
    "${local.name_prefix}-app-data" = {
      location                     = "US"  # Multi-region for HA
      storage_class               = "STANDARD"
      force_destroy               = false  # Protect production data
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = true
      labels                      = { purpose = "app-data", tier = "production", criticality = "high" }
      lifecycle_rules = [
        {
          action = {
            type          = "SetStorageClass"
            storage_class = "NEARLINE"
          }
          condition = {
            age = 30
          }
        },
        {
          action = {
            type          = "SetStorageClass"
            storage_class = "COLDLINE"
          }
          condition = {
            age = 90
          }
        }
      ]
      cors_rules       = []
      website_config   = null
      retention_policy = {
        retention_period = 86400  # 1 day minimum retention
        is_locked       = false
      }
      logging_config   = null
      kms_key_name    = var.enable_kms_encryption ? var.kms_key_name : null
    }
    "${local.name_prefix}-backups" = {
      location                     = "US"
      storage_class               = "COLDLINE"
      force_destroy               = false
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = true
      labels                      = { purpose = "backups", tier = "production", criticality = "high" }
      lifecycle_rules = [
        {
          action = {
            type = "Delete"
          }
          condition = {
            age = 2555  # 7 years retention
          }
        }
      ]
      cors_rules       = []
      website_config   = null
      retention_policy = {
        retention_period = 86400  # 1 day minimum retention
        is_locked       = false
      }
      logging_config   = null
      kms_key_name    = var.enable_kms_encryption ? var.kms_key_name : null
    }
    "${local.name_prefix}-static-assets" = {
      location                     = "US"
      storage_class               = "STANDARD"
      force_destroy               = false
      uniform_bucket_level_access = false  # Allow ACLs for CDN
      public_access_prevention    = "inherited"
      versioning_enabled          = true
      labels                      = { purpose = "static-assets", tier = "production" }
      lifecycle_rules = [
        {
          action = {
            type          = "SetStorageClass"
            storage_class = "NEARLINE"
          }
          condition = {
            age = 90
          }
        }
      ]
      cors_rules = [
        {
          origin  = var.allowed_cors_origins
          method  = ["GET", "HEAD"]
          response_header = ["Content-Type", "Cache-Control"]
          max_age_seconds = 86400
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
  
  # Production disk snapshots for backup
  snapshot_schedules = var.enable_disk_snapshots ? {
    "daily-snapshot" = {
      region                = var.region
      days_in_cycle         = 1
      start_time           = "02:00"  # 2 AM
      max_retention_days   = 30
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
      storage_locations    = ["us"]
      guest_flush          = true
      labels               = { schedule = "daily", tier = "production" }
    }
  } : {}
}
