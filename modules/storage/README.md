# Storage Module

This module manages Cloud Storage buckets and persistent disks with lifecycle management and backup features.

## Resources Created

- **Cloud Storage Buckets**: For object storage with lifecycle rules
- **Persistent Disks**: For VM storage with snapshots (optional)
- **Snapshot Schedules**: For automated backups (optional)

## Usage Examples

### Basic Storage Bucket
```hcl
module "storage" {
  source = "../modules/storage"
  
  project_id = "my-project"
  
  storage_buckets = {
    "my-app-data" = {
      location                     = "US"
      storage_class               = "STANDARD"
      force_destroy               = false
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      versioning_enabled          = true
      labels                      = { purpose = "app-data" }
      lifecycle_rules             = []
      cors_rules                  = []
      website_config              = null
      retention_policy            = null
      logging_config              = null
      kms_key_name               = null
    }
  }
}
```

### Bucket with Lifecycle Rules
```hcl
storage_buckets = {
  "my-archived-data" = {
    location                     = "US"
    storage_class               = "STANDARD"
    force_destroy               = false
    uniform_bucket_level_access = true
    public_access_prevention    = "enforced"
    versioning_enabled          = true
    labels                      = { purpose = "archived-data" }
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
          type = "Delete"
        }
        condition = {
          age = 365
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
```

### Persistent Disks with Snapshots
```hcl
persistent_disks = {
  "app-data-disk" = {
    type              = "pd-ssd"
    zone              = "us-central1-a"
    size              = 100
    image             = null
    kms_key_self_link = null
    labels            = { purpose = "app-data" }
  }
}

snapshot_schedules = {
  "daily-backup" = {
    region                = "us-central1"
    days_in_cycle         = 1
    start_time           = "03:00"
    max_retention_days   = 7
    on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    storage_locations    = ["us-central1"]
    guest_flush          = true
    labels               = { schedule = "daily" }
  }
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_id | GCP project ID | string | n/a |
| storage_buckets | Map of storage buckets to create | map(object) | {} |
| persistent_disks | Map of persistent disks to create | map(object) | {} |
| snapshot_schedules | Map of snapshot schedules | map(object) | {} |
| common_labels | Common labels for all resources | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| bucket_names | Map of bucket names |
| bucket_urls | Map of bucket URLs |
| disk_names | Map of persistent disk names |
