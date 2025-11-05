# Development Environment Outputs

output "project_info" {
  description = "Project information"
  value = {
    project_id   = var.project_id
    environment  = "dev"
    region       = var.region
  }
}

output "network_info" {
  description = "Network information"
  value = {
    network_id          = module.network.network_id
    network_name        = module.network.network_name
    public_subnet_ids   = module.network.public_subnet_ids
    private_subnet_ids  = module.network.private_subnet_ids
  }
}

output "compute_info" {
  description = "Compute information"
  value = {
    single_vm_name        = module.compute.single_vm_name
    single_vm_internal_ip = module.compute.single_vm_internal_ip
    single_vm_external_ip = module.compute.single_vm_external_ip
    service_account_email = module.compute.service_account_email
  }
}

output "storage_info" {
  description = "Storage information"
  value = {
    bucket_names = module.storage.bucket_names
    bucket_urls  = module.storage.bucket_urls
  }
}

output "iam_info" {
  description = "IAM information"
  value = {
    service_account_emails = module.iam.service_account_emails
  }
}

# Helpful information for getting started
output "getting_started" {
  description = "Getting started information"
  value = {
    ssh_command = module.compute.single_vm_name != null ? "gcloud compute ssh ${module.compute.single_vm_name} --zone=${var.region}-a --tunnel-through-iap" : "No VM created"
    web_url     = module.compute.single_vm_external_ip != null ? "http://${module.compute.single_vm_external_ip}" : "No external IP assigned"
    
    next_steps = [
      "1. Connect to your VM: gcloud compute ssh ${module.compute.single_vm_name} --zone=${var.region}-a --tunnel-through-iap",
      "2. View the web page: open http://${module.compute.single_vm_external_ip}",
      "3. Explore the GCP Console to see your resources",
      "4. Try modifying variables and running 'terraform plan'",
      "5. Enable create_instance_group to learn about managed instance groups"
    ]
  }
}
