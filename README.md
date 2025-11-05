We will learn and use Terraform Github Provider to provision an organization which acts as an umbrella for all the future child projects.

```
github-terraform/
│
├── README.md
├── .gitignore
│
├── main.tf                # Entry point: includes providers and module calls
├── providers.tf           # Provider configurations (GitHub, etc.)
├── variables.tf           # Variable definitions
├── outputs.tf             # Outputs (URLs, repo names, etc.)
│
├── terraform.tfvars       # Variable values (optional)
│
├── modules/               # Custom modules live here
│   └── organization/      # Module for managing GitHub org
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│
└── envs/                  # Environment-specific configs (optional)
    ├── dev/
    │   └── main.tf
    └── prod/
        └── main.tf
```