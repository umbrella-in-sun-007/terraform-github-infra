# GCP Storage Module - Cloud Storage Buckets, Persistent Disks
# Learn about GCP storage options here

# Cloud Storage Buckets
resource "google_storage_bucket" "buckets" {
  for_each = var.storage_buckets

  name          = each.key
  location      = each.value.location
  storage_class = each.value.storage_class
  project       = var.project_id

  # Prevent accidental deletion in production
  force_destroy = each.value.force_destroy

  # Uniform bucket-level access (recommended)
  uniform_bucket_level_access = each.value.uniform_bucket_level_access

  # Public access prevention
  public_access_prevention = each.value.public_access_prevention

  # Versioning
  versioning {
    enabled = each.value.versioning_enabled
  }

  # Lifecycle rules
  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state                 = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class      = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        days_since_custom_time     = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
      }
    }
  }

  # CORS configuration
  dynamic "cors" {
    for_each = each.value.cors_rules
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = lookup(cors.value, "response_header", [])
      max_age_seconds = lookup(cors.value, "max_age_seconds", 3600)
    }
  }

  # Website configuration
  dynamic "website" {
    for_each = each.value.website_config != null ? [each.value.website_config] : []
    content {
      main_page_suffix = website.value.main_page_suffix
      not_found_page   = lookup(website.value, "not_found_page", null)
    }
  }

  # Encryption
  dynamic "encryption" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = each.value.kms_key_name
    }
  }

  # Retention policy
  dynamic "retention_policy" {
    for_each = each.value.retention_policy != null ? [each.value.retention_policy] : []
    content {
      retention_period = retention_policy.value.retention_period
      is_locked        = lookup(retention_policy.value, "is_locked", false)
    }
  }

  # Logging
  dynamic "logging" {
    for_each = each.value.logging_config != null ? [each.value.logging_config] : []
    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = lookup(logging.value, "log_object_prefix", null)
    }
  }

  # Labels
  labels = merge(var.common_labels, each.value.labels)
}

# Bucket IAM bindings
resource "google_storage_bucket_iam_binding" "bucket_iam" {
  for_each = var.bucket_iam_bindings

  bucket  = google_storage_bucket.buckets[each.value.bucket_name].name
  role    = each.value.role
  members = each.value.members

  depends_on = [google_storage_bucket.buckets]
}

# Bucket notifications to Pub/Sub
resource "google_storage_notification" "bucket_notifications" {
  for_each = var.bucket_notifications

  bucket         = google_storage_bucket.buckets[each.value.bucket_name].name
  topic          = each.value.topic
  event_types    = each.value.event_types
  payload_format = each.value.payload_format
  object_name_prefix = lookup(each.value, "object_name_prefix", null)

  depends_on = [google_storage_bucket.buckets]
}

# Persistent Disks
resource "google_compute_disk" "persistent_disks" {
  for_each = var.persistent_disks

  name  = each.key
  type  = each.value.type
  zone  = each.value.zone
  size  = each.value.size
  image = each.value.image

  # Snapshot schedule
  dynamic "disk_encryption_key" {
    for_each = each.value.kms_key_self_link != null ? [1] : []
    content {
      kms_key_self_link = each.value.kms_key_self_link
    }
  }

  # Labels
  labels = merge(var.common_labels, each.value.labels)

  project = var.project_id
}

# Regional Persistent Disks (for high availability)
resource "google_compute_region_disk" "regional_disks" {
  for_each = var.regional_disks

  name          = each.key
  type          = each.value.type
  region        = each.value.region
  size          = each.value.size
  replica_zones = each.value.replica_zones

  # Snapshot source
  snapshot = lookup(each.value, "snapshot", null)

  # Encryption
  dynamic "disk_encryption_key" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      kms_key_name = each.value.kms_key_name
    }
  }

  # Labels
  labels = merge(var.common_labels, each.value.labels)

  project = var.project_id
}

# Disk snapshots for backup
resource "google_compute_snapshot" "disk_snapshots" {
  for_each = var.disk_snapshots

  name        = each.key
  source_disk = each.value.source_disk
  zone        = each.value.zone

  # Snapshot retention
  storage_locations = each.value.storage_locations

  # Labels
  labels = merge(var.common_labels, each.value.labels)

  project = var.project_id
}

# Snapshot schedule
resource "google_compute_resource_policy" "snapshot_schedule" {
  for_each = var.snapshot_schedules

  name   = each.key
  region = each.value.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = each.value.days_in_cycle
        start_time    = each.value.start_time
      }
    }

    retention_policy {
      max_retention_days    = each.value.max_retention_days
      on_source_disk_delete = each.value.on_source_disk_delete
    }

    snapshot_properties {
      labels            = merge(var.common_labels, each.value.labels)
      storage_locations = each.value.storage_locations
      guest_flush       = each.value.guest_flush
    }
  }

  project = var.project_id
}

# Attach snapshot schedule to disks
resource "google_compute_disk_resource_policy_attachment" "snapshot_attachment" {
  for_each = var.disk_snapshot_attachments

  name = google_compute_resource_policy.snapshot_schedule[each.value.policy_name].name
  disk = google_compute_disk.persistent_disks[each.value.disk_name].name
  zone = google_compute_disk.persistent_disks[each.value.disk_name].zone

  project = var.project_id
}
