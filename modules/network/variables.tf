variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "delete_default_routes" {
  description = "Delete default routes on VPC creation"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_secondary_ranges" {
  description = "Enable secondary IP ranges for GKE"
  type        = bool
  default     = false
}

variable "pod_ip_ranges" {
  description = "Secondary IP ranges for GKE pods"
  type        = list(string)
  default     = ["10.1.0.0/16", "10.2.0.0/16"]
}

variable "service_ip_ranges" {
  description = "Secondary IP ranges for GKE services"
  type        = list(string)
  default     = ["10.3.0.0/20", "10.4.0.0/20"]
}

variable "common_tags" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}
