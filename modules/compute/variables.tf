variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "subnet_self_link" {
  description = "Self link of the subnet"
  type        = string
}

variable "machine_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-micro"
}

variable "source_image" {
  description = "Source image for VM instances"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  type        = string
  default     = "pd-standard"
}

variable "assign_public_ip" {
  description = "Assign public IP to instances"
  type        = bool
  default     = false
}

variable "preemptible" {
  description = "Use preemptible instances (cost-effective for dev)"
  type        = bool
  default     = true
}

variable "enable_shielded_vm" {
  description = "Enable Shielded VM security features"
  type        = bool
  default     = true
}

variable "network_tags" {
  description = "Network tags for firewall rules"
  type        = list(string)
  default     = ["allow-iap-ssh"]
}

variable "metadata" {
  description = "Metadata key-value pairs"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Startup script for instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
  EOF
}

variable "vm_service_account_roles" {
  description = "IAM roles for the VM service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
}

variable "vm_scopes" {
  description = "OAuth scopes for the VM service account"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

# Managed Instance Group variables
variable "create_single_vm" {
  description = "Create a single VM instance for testing"
  type        = bool
  default     = true
}

variable "create_instance_group" {
  description = "Create a managed instance group"
  type        = bool
  default     = false
}

variable "target_size" {
  description = "Target number of instances in the group"
  type        = number
  default     = 2
}

variable "health_check_self_link" {
  description = "Self link of the health check"
  type        = string
  default     = null
}

variable "auto_healing_delay" {
  description = "Initial delay for auto-healing in seconds"
  type        = number
  default     = 300
}

variable "max_surge" {
  description = "Maximum number of instances that can be created during update"
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Maximum number of instances that can be unavailable during update"
  type        = number
  default     = 1
}

variable "named_ports" {
  description = "Named ports for load balancer"
  type = list(object({
    name = string
    port = number
  }))
  default = [
    {
      name = "http"
      port = 80
    }
  ]
}

# Auto-scaling variables
variable "enable_autoscaling" {
  description = "Enable autoscaling for the instance group"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 5
}

variable "cpu_utilization_target" {
  description = "CPU utilization target for autoscaling"
  type        = number
  default     = 0.6
}

variable "cooldown_period" {
  description = "Cooldown period for autoscaling in seconds"
  type        = number
  default     = 60
}
