# Network Module

This module creates a VPC network with public and private subnets, NAT gateway, and firewall rules.

## Resources Created

- **VPC Network**: Main network for your resources
- **Public Subnets**: For resources that need direct internet access
- **Private Subnets**: For internal resources without direct internet access
- **Cloud Router**: Required for NAT gateway
- **NAT Gateway**: Allows private instances to access the internet
- **Firewall Rules**: Security rules for SSH, internal communication, and health checks

## Usage Example

```hcl
module "network" {
  source = "../modules/network"
  
  name_prefix = "my-project"
  environment = "dev"
  region      = "us-central1"
  
  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24"]
  
  enable_nat_gateway = true
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name_prefix | Prefix for resource names | string | n/a |
| environment | Environment name | string | n/a |
| region | GCP region | string | n/a |
| public_subnet_cidrs | CIDR blocks for public subnets | list(string) | n/a |
| private_subnet_cidrs | CIDR blocks for private subnets | list(string) | n/a |
| enable_nat_gateway | Enable NAT Gateway | bool | true |

## Outputs

| Name | Description |
|------|-------------|
| network_self_link | VPC network self link |
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
