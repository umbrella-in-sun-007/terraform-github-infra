variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# Cloud Storage Buckets
variable "storage_buckets" {
  description = "Map of storage buckets to create"
  type = map(object({
    location                     = string
    storage_class               = string
    force_destroy               = bool
    uniform_bucket_level_access = bool
    public_access_prevention    = string
    versioning_enabled          = bool
    kms_key_name               = optional(string)
    labels                     = map(string)
    
    lifecycle_rules = list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                        = optional(number)
        created_before             = optional(string)
        with_state                 = optional(string)
        matches_storage_class      = optional(list(string))
        num_newer_versions         = optional(number)
        days_since_custom_time     = optional(number)
        days_since_noncurrent_time = optional(number)
      })
    }))
    
    cors_rules = list(object({
      origin          = list(string)
      method          = list(string)
      response_header = optional(list(string))
      max_age_seconds = optional(number)
    }))
    
    website_config = optional(object({
      main_page_suffix = string
      not_found_page   = optional(string)
    }))
    
    retention_policy = optional(object({
      retention_period = number
      is_locked       = optional(bool)
    }))
    
    logging_config = optional(object({
      log_bucket        = string
      log_object_prefix = optional(string)
    }))
  }))
  default = {}
}

# Bucket IAM
variable "bucket_iam_bindings" {
  description = "Map of bucket IAM bindings"
  type = map(object({
    bucket_name = string
    role        = string
    members     = list(string)
  }))
  default = {}
}

# Bucket Notifications
variable "bucket_notifications" {
  description = "Map of bucket notifications to Pub/Sub"
  type = map(object({
    bucket_name        = string
    topic              = string
    event_types        = list(string)
    object_name_prefix = optional(string)
    payload_format     = string
  }))
  default = {}
}

# Persistent Disks
variable "persistent_disks" {
  description = "Map of persistent disks to create"
  type = map(object({
    type              = string
    zone              = string
    size              = number
    image             = optional(string)
    kms_key_self_link = optional(string)
    labels            = map(string)
  }))
  default = {}
}

# Regional Disks
variable "regional_disks" {
  description = "Map of regional persistent disks to create"
  type = map(object({
    type          = string
    region        = string
    size          = number
    replica_zones = list(string)
    snapshot      = optional(string)
    kms_key_name  = optional(string)
    labels        = map(string)
  }))
  default = {}
}

# Disk Snapshots
variable "disk_snapshots" {
  description = "Map of disk snapshots to create"
  type = map(object({
    source_disk       = string
    zone              = string
    storage_locations = list(string)
    labels            = map(string)
  }))
  default = {}
}

# Snapshot Schedules
variable "snapshot_schedules" {
  description = "Map of snapshot schedules to create"
  type = map(object({
    region                = string
    days_in_cycle         = number
    start_time           = string
    max_retention_days   = number
    on_source_disk_delete = string
    storage_locations    = list(string)
    guest_flush          = bool
    labels               = map(string)
  }))
  default = {}
}

# Snapshot Attachments
variable "disk_snapshot_attachments" {
  description = "Map of disk to snapshot schedule attachments"
  type = map(object({
    disk_name   = string
    policy_name = string
  }))
  default = {}
}
