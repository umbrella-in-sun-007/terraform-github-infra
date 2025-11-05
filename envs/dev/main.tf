# Development Environment Configuration

# Local values for this environment
locals {
  environment = "dev"
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
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway       = var.enable_nat_gateway
  enable_secondary_ranges  = false
  
  common_tags = local.common_labels
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  project_id = var.project_id
  
  service_accounts = {
    "dev-compute-sa" = {
      display_name = "Dev Compute Service Account"
      description  = "Service account for compute instances in dev environment"
    }
    "dev-storage-sa" = {
      display_name = "Dev Storage Service Account"
      description  = "Service account for storage operations in dev environment"
    }
  }
  
  project_iam_bindings = {
    "roles/compute.instanceAdmin.v1" = [
      "serviceAccount:${module.iam.service_account_emails["dev-compute-sa"]}"
    ]
    "roles/storage.objectAdmin" = [
      "serviceAccount:${module.iam.service_account_emails["dev-storage-sa"]}"
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
  subnet_self_link    = module.network.public_subnet_ids[0]
  
  machine_type        = var.machine_type
  create_single_vm    = true
  assign_public_ip    = true
  preemptible         = true
  
  create_instance_group = var.create_instance_group
  enable_autoscaling    = false
  target_size          = 1
  
  network_tags = ["dev-vm", "allow-iap-ssh"]
  
  startup_script = var.startup_script
}

# Storage Module
module "storage" {
  source = "../../modules/storage"
  
  project_id     = var.project_id
  common_labels  = local.common_labels
  
  storage_buckets = {
    "${local.name_prefix}-app-data" = {
      location                     = var.region
      storage_class               = "STANDARD"
      force_destroy               = true
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = false
      labels                      = { purpose = "app-data" }
      lifecycle_rules             = []
      cors_rules                  = []
      website_config              = null
      retention_policy            = null
      logging_config              = null
      kms_key_name               = null
    }
    "${local.name_prefix}-backups" = {
      location                     = var.region
      storage_class               = "NEARLINE"
      force_destroy               = true
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = true
      labels                      = { purpose = "backups" }
      lifecycle_rules = [
        {
          action = {
            type = "Delete"
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
  }
  
  persistent_disks = var.create_extra_disks ? {
    "${local.name_prefix}-data-disk" = {
      type              = "pd-standard"
      zone              = "${var.region}-a"
      size              = 10
      image             = null
      kms_key_self_link = null
      labels            = { purpose = "data" }
    }
  } : {}
}
