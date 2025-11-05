# Infrastructure Project

A modular Terraform project structure for managing cloud infrastructure across multiple environments.

## Project Structure

```
├── modules/                    # Reusable Terraform modules
│   ├── network/               # Networking components
│   ├── compute/               # Compute resources
│   ├── iam/                   # Identity and access management
│   └── storage/               # Storage resources
├── envs/                      # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── staging/               # Staging environment
│   └── prod/                  # Production environment
├── global/                    # Global configurations
│   ├── provider.tf            # Provider configuration
│   ├── versions.tf            # Version constraints
│   └── variables.tf           # Global variables
└── README.md                  # This file
```

## Getting Started

1. **Configure Variables**
   ```bash
   cd envs/dev
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your project-specific values
   ```

2. **Initialize and Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Usage

Each environment can be deployed independently:
- `envs/dev/` - Development environment
- `envs/staging/` - Staging environment  
- `envs/prod/` - Production environment

Modify the variables in each environment's `terraform.tfvars` file to customize the deployment.
