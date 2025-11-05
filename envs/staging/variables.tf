# Staging Environment Variables

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
  description = "GCP region for staging environment"
  type        = string
  default     = "us-central1"
}

# Networking variables
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
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
  default     = ["10.2.0.0/16", "10.3.0.0/16"]
}

variable "service_ip_ranges" {
  description = "Secondary IP ranges for GKE services"
  type        = list(string)
  default     = ["10.4.0.0/20", "10.5.0.0/20"]
}

# Compute variables
variable "machine_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-small"
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for instance groups"
  type        = bool
  default     = true
}

variable "target_size" {
  description = "Target number of instances"
  type        = number
  default     = 2
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 5
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
    
    # Create staging web page
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Staging Environment - $(hostname)</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #fff3cd; }
            .container { max-width: 800px; margin: 0 auto; }
            .info { background: #f8f9fa; padding: 20px; border-radius: 5px; border-left: 4px solid #ffc107; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🎭 Staging Environment</h1>
            <div class="info">
                <h3>Server Information</h3>
                <p><strong>Hostname:</strong> $(hostname)</p>
                <p><strong>Environment:</strong> Staging</p>
                <p><strong>Instance Group:</strong> Yes</p>
                <p><strong>Auto-scaling:</strong> Enabled</p>
                <p><strong>Date:</strong> $(date)</p>
            </div>
        </div>
    </body>
    </html>
HTML
    
    echo "Staging environment setup complete!" > /var/log/startup-script.log
  EOF
}
