# Terraform GitHub Provider — Organization Provisioning

Terraform provisions GitHub infrastructure using the **GitHub Provider**. We use HCL (Hashicorp Configuration Language) to define repositories, organization settings, and CI/CD automation.

## What this project does

* Provisions a **private repo** in a personal GitHub account.
* Provisions a **public repo** in a GitHub **organization**.
* Sets up a **CI GitHub Action** that syncs the main branch (production) between repos.

## Directory Structure

```
github-terraform/
├── .github
│   └── workflows
│       └── sync-to-org.yml        # CI workflow for syncing repositories
├── .gitignore                     # Ignore Terraform state & local files
├── main.tf                        # Root Terraform configuration
├── modules
│   └── organization
│       ├── main.tf                # Organization module logic
│       ├── outputs.tf             # Module outputs
│       └── variables.tf           # Module variables
├── Notes.md                       # Development and usage notes
├── outputs.tf                     # Root-level Terraform outputs
├── Provider.md                    # Provider documentation and setup notes
├── README.md                      # Project documentation
└── variables.tf                   # Input variable definitions
```

## Features

### 1. GitHub Organization Provisioning

* Uses **Terraform GitHub Provider** to manage org-level repositories.
* Defines access, visibility, and metadata.

### 2. Repository Management

* Private repo (user-owned)
* Public repo (org-owned)
* Repeatable creation using Terraform code

### 3. CI/CD Automation via GitHub Actions

* Workflow runs on every push to `main`.
* Syncs changes to the org repo.
* Prevents redundant runs.

## Prerequisites

* Terraform ≥ 1.6
* GitHub PAT with scopes:

  * `repo`
  * `admin:org`
  * `workflow`
* A GitHub Organization
* Git CLI access to both repos

## Steps to Run

**1. Clone repo**

```bash
git clone https://github.com/<your-username>/github-terraform.git
cd github-terraform
```

**2. Set environment variables**

```bash
export GITHUB_TOKEN=<your_pat>
export GITHUB_OWNER=<your_github_username_or_org>
```

**3. Initialize Terraform**

```bash
terraform init
```

**4. Plan changes**

```bash
terraform plan
```

**5. Apply changes**

```bash
terraform apply
```

Confirm to create repos and configurations.

## sync-to-org.yml (CI Workflow)

This workflow automates synchronization between the personal and org repositories.

**Trigger:**

* Push to `main`

**Purpose:**

* Clone private repo
* Push latest commits to org repo
* Prevent reruns

## Files Overview

| File                                | Purpose                               |
| ----------------------------------- | ------------------------------------- |
| `main.tf`                           | Root configuration calling the module |
| `variables.tf`                      | Input variables for org, repos, etc.  |
| `outputs.tf`                        | Outputs details of created repos      |
| `modules/organization/main.tf`      | Module logic for repo creation        |
| `.github/workflows/sync-to-org.yml` | CI/CD automation file                 |
| `Provider.md`                       | Notes for provider setup              |
| `Notes.md`                          | Local reference and notes             |

## Concepts Covered

* **IaC (Infrastructure as Code)** using HCL
* **Modules** for reusable org provisioning
* **Provider Authentication** using PAT
* **Automation** through CI/CD

## Example Outputs

```hcl
Outputs:
organization_name = "my-org"
public_repo_url   = "https://github.com/my-org/public-repo"
private_repo_url  = "https://github.com/my-username/private-repo"
```

## Tools Used

* Terraform (HashiCorp)
* GitHub Provider
* GitHub Actions

## Future Plans

* Add branch protection rules
* Automate team creation and permissions
* Manage secrets with Terraform
* Extend sync to multiple child projects

## References

* [Terraform GitHub Provider Docs](https://registry.terraform.io/providers/integrations/github/latest/docs)
* [GitHub Actions Docs](https://docs.github.com/en/actions)
* [Terraform Modules Guide](https://developer.hashicorp.com/terraform/language/modules/develop)

## Author

**Adhav Neeraj Sahebrao**
Postgraduate | Cloud Infrastructure & DevOps | Terraform | GCP | GitHub Automation
