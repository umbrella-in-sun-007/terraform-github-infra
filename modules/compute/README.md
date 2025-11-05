# Compute Module

This module creates compute resources including VM instances, instance templates, and managed instance groups.

## Resources Created

- **Service Account**: Dedicated service account for VM instances
- **Instance Template**: Template for creating consistent VM instances
- **Single VM**: For testing (optional)
- **Managed Instance Group**: For auto-scaling applications (optional)
- **Autoscaler**: Automatically scales instances based on CPU usage (optional)

## Usage Examples

### Single VM
```hcl
module "compute" {
  source = "../modules/compute"
  
  name_prefix         = "my-project"
  environment         = "dev"
  project_id          = "my-gcp-project"
  network_self_link   = module.network.network_self_link
  subnet_self_link    = module.network.public_subnet_ids[0]
  
  create_single_vm    = true
  assign_public_ip    = true
  machine_type        = "e2-micro"
  preemptible         = true
}
```

### Managed Instance Group with Auto-scaling
```hcl
module "compute" {
  source = "../modules/compute"
  
  name_prefix         = "my-project"
  environment         = "prod"
  project_id          = "my-gcp-project"
  network_self_link   = module.network.network_self_link
  subnet_self_link    = module.network.private_subnet_ids[0]
  
  create_single_vm      = false
  create_instance_group = true
  enable_autoscaling    = true
  
  target_size     = 2
  min_replicas    = 1
  max_replicas    = 10
  
  machine_type    = "e2-standard-2"
  preemptible     = false
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name_prefix | Prefix for resource names | string | n/a |
| environment | Environment name | string | n/a |
| project_id | GCP project ID | string | n/a |
| network_self_link | VPC network self link | string | n/a |
| subnet_self_link | Subnet self link | string | n/a |
| machine_type | VM machine type | string | "e2-micro" |
| create_single_vm | Create single VM | bool | false |
| create_instance_group | Create managed instance group | bool | false |

## Outputs

| Name | Description |
|------|-------------|
| service_account_email | Service account email |
| instance_group_manager_self_link | Instance group manager self link |
| single_vm_name | Single VM instance name |
