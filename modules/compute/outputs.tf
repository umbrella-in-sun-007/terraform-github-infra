output "service_account_email" {
  description = "Email of the VM service account"
  value       = google_service_account.vm_service_account.email
}

output "instance_template_id" {
  description = "ID of the instance template"
  value       = google_compute_instance_template.main.id
}

output "instance_template_self_link" {
  description = "Self link of the instance template"
  value       = google_compute_instance_template.main.self_link
}

output "single_vm_id" {
  description = "ID of the single VM instance (if created)"
  value       = var.create_single_vm ? google_compute_instance.single_vm[0].id : null
}

output "single_vm_name" {
  description = "Name of the single VM instance (if created)"
  value       = var.create_single_vm ? google_compute_instance.single_vm[0].name : null
}

output "single_vm_internal_ip" {
  description = "Internal IP of the single VM instance (if created)"
  value       = var.create_single_vm ? google_compute_instance.single_vm[0].network_interface[0].network_ip : null
}

output "single_vm_external_ip" {
  description = "External IP of the single VM instance (if created and has public IP)"
  value = var.create_single_vm && var.assign_public_ip ? (
    length(google_compute_instance.single_vm[0].network_interface[0].access_config) > 0 ?
    google_compute_instance.single_vm[0].network_interface[0].access_config[0].nat_ip : null
  ) : null
}

output "instance_group_id" {
  description = "ID of the managed instance group (if created)"
  value       = var.create_instance_group ? google_compute_region_instance_group_manager.main[0].id : null
}

output "instance_group_self_link" {
  description = "Self link of the managed instance group (if created)"
  value       = var.create_instance_group ? google_compute_region_instance_group_manager.main[0].self_link : null
}

output "autoscaler_id" {
  description = "ID of the autoscaler (if created)"
  value       = var.create_instance_group && var.enable_autoscaling ? google_compute_region_autoscaler.main[0].id : null
}
