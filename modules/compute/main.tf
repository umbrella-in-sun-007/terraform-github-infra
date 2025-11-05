# GCP Compute Module - VM Instances, Instance Templates, Managed Instance Groups
# Learn about GCP compute concepts here

# Service Account for VM instances
resource "google_service_account" "vm_service_account" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "VM Service Account for ${var.environment}"
  description  = "Service account for VM instances in ${var.environment} environment"
}

# IAM binding for service account
resource "google_project_iam_member" "vm_service_account_roles" {
  for_each = toset(var.vm_service_account_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

# Instance template for managed instance groups
resource "google_compute_instance_template" "main" {
  name_prefix = "${var.name_prefix}-template-"
  description = "Instance template for ${var.environment} environment"
  
  # This allows Terraform to create a new template before destroying the old one
  lifecycle {
    create_before_destroy = true
  }

  machine_type = var.machine_type
  region       = var.region

  # Boot disk configuration
  disk {
    source_image = var.source_image
    disk_size_gb = var.boot_disk_size
    disk_type    = var.boot_disk_type
    boot         = true
    auto_delete  = true
  }

  # Network interface
  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnet_self_link
    
    # Don't assign external IP if in private subnet
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        # Ephemeral external IP
      }
    }
  }

  # Metadata
  metadata = merge(var.metadata, {
    # Enable OS Login for better security
    enable-oslogin = "TRUE"
    # Startup script
    startup-script = var.startup_script
  })

  # Service account
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = var.vm_scopes
  }

  # Network tags for firewall rules
  tags = var.network_tags

  # Scheduling - preemptible instances for cost savings in dev
  scheduling {
    preemptible       = var.preemptible
    automatic_restart = !var.preemptible
  }

  # Shielded VM settings (security best practice)
  shielded_instance_config {
    enable_secure_boot          = var.enable_shielded_vm
    enable_vtpm                 = var.enable_shielded_vm
    enable_integrity_monitoring = var.enable_shielded_vm
  }
}

# Single VM instance (for learning/testing)
resource "google_compute_instance" "single_vm" {
  count = var.create_single_vm ? 1 : 0
  
  name         = "${var.name_prefix}-single-vm"
  machine_type = var.machine_type
  zone         = "${var.region}-a"
  
  boot_disk {
    initialize_params {
      image = var.source_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnet_self_link
    
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        # Ephemeral external IP
      }
    }
  }

  metadata = merge(var.metadata, {
    enable-oslogin = "TRUE"
    startup-script = var.startup_script
  })

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = var.vm_scopes
  }

  tags = var.network_tags

  scheduling {
    preemptible       = var.preemptible
    automatic_restart = !var.preemptible
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_shielded_vm
    enable_vtpm                 = var.enable_shielded_vm
    enable_integrity_monitoring = var.enable_shielded_vm
  }
}

# Managed Instance Group (for auto-scaling)
resource "google_compute_region_instance_group_manager" "main" {
  count = var.create_instance_group ? 1 : 0
  
  name   = "${var.name_prefix}-mig"
  region = var.region

  base_instance_name = "${var.name_prefix}-instance"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.main.id
    name              = "primary"
  }

  # Auto healing policy
  auto_healing_policies {
    health_check      = var.health_check_self_link
    initial_delay_sec = var.auto_healing_delay
  }

  # Update policy for rolling updates
  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = var.max_surge
    max_unavailable_fixed        = var.max_unavailable
  }

  # Named ports for load balancer
  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

# Auto-scaler for the managed instance group
resource "google_compute_region_autoscaler" "main" {
  count = var.create_instance_group && var.enable_autoscaling ? 1 : 0
  
  name   = "${var.name_prefix}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.main[0].id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    # CPU utilization target
    cpu_utilization {
      target = var.cpu_utilization_target
    }
  }
}
