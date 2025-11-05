# Production Environment Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-tuts"
}

variable "region" {
  description = "GCP region for production environment"
  type        = string
  default     = "us-east1"
}

# Networking variables
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.2.3.0/24", "10.2.4.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_gke_ranges" {
  description = "Enable secondary IP ranges for GKE"
  type        = bool
  default     = true
}

variable "pod_ip_ranges" {
  description = "Secondary IP ranges for GKE pods"
  type        = list(string)
  default     = ["10.6.0.0/16", "10.7.0.0/16"]
}

variable "service_ip_ranges" {
  description = "Secondary IP ranges for GKE services"
  type        = list(string)
  default     = ["10.8.0.0/20", "10.9.0.0/20"]
}

# Compute variables
variable "machine_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-standard-2"
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for instance groups"
  type        = bool
  default     = true
}

variable "target_size" {
  description = "Target number of instances"
  type        = number
  default     = 3
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 3
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 10
}

# Security variables
variable "enable_kms_encryption" {
  description = "Enable KMS encryption for storage"
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = "KMS key name for encryption"
  type        = string
  default     = null
}

variable "allowed_cors_origins" {
  description = "Allowed CORS origins for static assets"
  type        = list(string)
  default     = ["https://example.com"]
}

variable "enable_disk_snapshots" {
  description = "Enable automated disk snapshots"
  type        = bool
  default     = true
}

variable "startup_script" {
  description = "Startup script for VM instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx htop
    systemctl enable nginx
    systemctl start nginx
    
    # Create production web page
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Production Environment - $(hostname)</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #d4edda; }
            .container { max-width: 800px; margin: 0 auto; }
            .info { background: #f8f9fa; padding: 20px; border-radius: 5px; border-left: 4px solid #28a745; }
            .warning { background: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107; margin-top: 20px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Production Environment</h1>
            <div class="info">
                <h3>Server Information</h3>
                <p><strong>Hostname:</strong> $(hostname)</p>
                <p><strong>Environment:</strong> Production</p>
                <p><strong>Instance Group:</strong> Yes</p>
                <p><strong>Auto-scaling:</strong> Enabled</p>
                <p><strong>High Availability:</strong> Multi-zone</p>
                <p><strong>Date:</strong> $(date)</p>
            </div>
            <div class="warning">
                <strong>⚠️ Production Environment:</strong> Handle with care!
            </div>
        </div>
    </body>
    </html>
HTML
    
    echo "Production environment setup complete!" > /var/log/startup-script.log
  EOF
}
