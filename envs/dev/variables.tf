# Development Environment Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "my-project"
}

variable "region" {
  description = "GCP region for dev environment"
  type        = string
  default     = "us-central1"
}

# Networking variables
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# Compute variables
variable "machine_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-micro"
}

variable "create_instance_group" {
  description = "Create a managed instance group for learning"
  type        = bool
  default     = false
}

variable "create_extra_disks" {
  description = "Create additional persistent disks for learning"
  type        = bool
  default     = false
}

variable "startup_script" {
  description = "Startup script for VM instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx htop tree
    systemctl enable nginx
    systemctl start nginx
    
    # Create a simple web page
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>$(hostname)</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .info { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Server Ready</h1>
            <div class="info">
                <h3>Server Information</h3>
                <p><strong>Hostname:</strong> $(hostname)</p>
                <p><strong>Date:</strong> $(date)</p>
            </div>
        </div>
    </body>
    </html>
HTML
    
    echo "Server setup complete!" > /var/log/startup-script.log
  EOF
}
