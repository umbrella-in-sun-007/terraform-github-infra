output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.main.self_link
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = google_compute_subnetwork.public[*].id
}

output "public_subnet_names" {
  description = "Names of the public subnets"
  value       = google_compute_subnetwork.public[*].name
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = google_compute_subnetwork.private[*].id
}

output "private_subnet_names" {
  description = "Names of the private subnets"
  value       = google_compute_subnetwork.private[*].name
}

output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.main.id
}

output "nat_gateway_name" {
  description = "Name of the NAT Gateway (if enabled)"
  value       = var.enable_nat_gateway ? google_compute_router_nat.main[0].name : null
}
