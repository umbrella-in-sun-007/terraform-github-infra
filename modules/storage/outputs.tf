output "bucket_names" {
  description = "Map of bucket names"
  value = {
    for name, bucket in google_storage_bucket.buckets : name => bucket.name
  }
}

output "bucket_urls" {
  description = "Map of bucket URLs"
  value = {
    for name, bucket in google_storage_bucket.buckets : name => bucket.url
  }
}

output "bucket_self_links" {
  description = "Map of bucket self links"
  value = {
    for name, bucket in google_storage_bucket.buckets : name => bucket.self_link
  }
}

output "persistent_disk_ids" {
  description = "Map of persistent disk IDs"
  value = {
    for name, disk in google_compute_disk.persistent_disks : name => disk.id
  }
}

output "persistent_disk_self_links" {
  description = "Map of persistent disk self links"
  value = {
    for name, disk in google_compute_disk.persistent_disks : name => disk.self_link
  }
}

output "regional_disk_ids" {
  description = "Map of regional disk IDs"
  value = {
    for name, disk in google_compute_region_disk.regional_disks : name => disk.id
  }
}

output "snapshot_ids" {
  description = "Map of snapshot IDs"
  value = {
    for name, snapshot in google_compute_snapshot.disk_snapshots : name => snapshot.id
  }
}

output "snapshot_schedule_ids" {
  description = "Map of snapshot schedule IDs"
  value = {
    for name, schedule in google_compute_resource_policy.snapshot_schedule : name => schedule.id
  }
}
