# Network Module - VPC, Subnets, Firewall Rules

# Main VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  description             = "Main VPC network for ${var.environment} environment"
  
  delete_default_routes_on_create = var.delete_default_routes
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  count = length(var.public_subnet_cidrs)
  
  name          = "${var.name_prefix}-public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.main.id
  description   = "Public subnet ${count.index + 1} for ${var.environment}"
  
  private_ip_google_access = true
  
  # Secondary IP ranges for GKE pods and services
  dynamic "secondary_ip_range" {
    for_each = var.enable_secondary_ranges ? [1] : []
    content {
      range_name    = "${var.name_prefix}-pods-${count.index + 1}"
      ip_cidr_range = var.pod_ip_ranges[count.index]
    }
  }
  
  dynamic "secondary_ip_range" {
    for_each = var.enable_secondary_ranges ? [1] : []
    content {
      range_name    = "${var.name_prefix}-services-${count.index + 1}"
      ip_cidr_range = var.service_ip_ranges[count.index]
    }
  }
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  count = length(var.private_subnet_cidrs)
  
  name          = "${var.name_prefix}-private-subnet-${count.index + 1}"
  ip_cidr_range = var.private_subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.main.id
  description   = "Private subnet ${count.index + 1} for ${var.environment}"
  
  private_ip_google_access = true
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "main" {
  name    = "${var.name_prefix}-router"
  region  = var.region
  network = google_compute_network.main.id
  
  description = "Router for NAT gateway in ${var.environment}"
}

# NAT Gateway for outbound internet access from private subnets
resource "google_compute_router_nat" "main" {
  count = var.enable_nat_gateway ? 1 : 0
  
  name   = "${var.name_prefix}-nat-gateway"
  router = google_compute_router.main.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule to allow SSH from IAP
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.name_prefix}-allow-iap-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-iap-ssh"]
  
  description = "Allow SSH access from Identity-Aware Proxy"
}

# Firewall rule to allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name_prefix}-allow-internal"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = concat(var.public_subnet_cidrs, var.private_subnet_cidrs)
  description   = "Allow internal communication between subnets"
}

# Firewall rule to allow health checks from Google Cloud Load Balancer
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.name_prefix}-allow-health-check"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
  
  description = "Allow health checks from Google Cloud Load Balancer"
}
