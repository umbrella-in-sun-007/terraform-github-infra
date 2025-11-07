# GitHub Repository Provisioning with Terraform

This Terraform project provisions **private repositories** in both your personal GitHub account and a GitHub organization. It also adds a **GitHub Actions workflow** for automatically syncing changes between repositories.
Both repositories’ names and descriptions are fully configurable.

---

## What This Project Does

* Creates a **private repository** in your personal GitHub account
* Creates a **private repository** in a GitHub organization
* Adds a **GitHub Actions workflow** to both repositories for syncing changes
* Allows **custom repository names and descriptions** for both repos

---

## Features

### Repository Creation

* Creates private repositories in both personal and organization accounts
* Configurable repository names and descriptions
* Enables **issues**, **projects**, and **wiki** features
* Automatically deletes merged branches

### GitHub Actions Workflow

* Syncs the **main branch** from personal repo → organization repo
* Uses **secure GitHub secrets** for authentication
* Supports **skip-sync** commit messages to prevent infinite loops
* Configurable credentials for commits and sync operations

---

## Prerequisites

* **Terraform ≥ 1.0.0**
* **GitHub Personal Access Token (PAT)** with scopes:

  * `repo` — Full control of private repositories
  * `admin:org` — Full control of orgs and teams
  * `workflow` — Update GitHub Actions workflows
* Access to a **GitHub organization** where you’ll create repositories

---

## Directory Structure

```
terraform-github-repos/
├── .github/
│   └── workflows/
│       ├── sync-to-org.yml         # Final GitHub Actions workflow
│       └── sync-to-org.yml.tpl     # Template injected by Terraform
├── main.tf                         # Main Terraform configuration
├── variables.tf                    # Input variable definitions
├── outputs.tf                      # Output definitions
├── terraform.tfvars.example        # Example configuration file
└── README.md                       # This file
```

---

## Configuration

### 1. Create Your Variables File

Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit `terraform.tfvars`

```hcl
# Required variables
github_token = "ghp_your_personal_access_token"
personal_github_username = "your-username"
personal_github_email = "your-email@example.com"
organization_name = "your-organization-name"

# Optional (defaults provided)
personal_repo_name        = "my-personal-project"
personal_repo_description = "My personal project repository"
organization_repo_name    = "my-org-project"
organization_repo_description = "Organization project repository"
```

---

## GitHub Secret Setup

For the workflow to function properly, add a secret to your personal repository:

1. Go to **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Name it **`SYNC_TOKEN`**
4. Use the same GitHub PAT value as `github_token`

---

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan Deployment

```bash
terraform plan
```

### 3. Apply Configuration

```bash
terraform apply
```

Confirm with `yes` to create both repositories.

### 4. View Outputs

After successful deployment, Terraform displays:

* Repository URLs (web, HTTPS, SSH)
* Repository names
* Workflow file paths

---

## Variables

| Variable                        | Description                   | Type   | Default                                            | Required |
| ------------------------------- | ----------------------------- | ------ | -------------------------------------------------- | -------- |
| `github_token`                  | GitHub Personal Access Token  | string | —                                                  | Yes      |
| `personal_github_username`      | Your GitHub username          | string | —                                                  | Yes      |
| `personal_github_email`         | Your GitHub email             | string | —                                                  | Yes      |
| `organization_name`             | Target organization name      | string | —                                                  | Yes      |
| `personal_repo_name`            | Personal repo name            | string | `"my-personal-repo"`                               | No       |
| `personal_repo_description`     | Personal repo description     | string | `"Personal repository created with Terraform"`     | No       |
| `organization_repo_name`        | Organization repo name        | string | `"my-org-repo"`                                    | No       |
| `organization_repo_description` | Organization repo description | string | `"Organization repository created with Terraform"` | No       |

---

## Outputs

| Output                                  | Description                             |
| --------------------------------------- | --------------------------------------- |
| `personal_repository_url`               | Personal repository web URL             |
| `personal_repository_git_clone_url`     | Personal repository HTTPS clone URL     |
| `personal_repository_ssh_url`           | Personal repository SSH URL             |
| `organization_repository_url`           | Organization repository web URL         |
| `organization_repository_git_clone_url` | Organization repository HTTPS clone URL |
| `organization_repository_ssh_url`       | Organization repository SSH URL         |
| `personal_repository_name`              | Personal repository name                |
| `organization_repository_name`          | Organization repository name            |
| `personal_workflow_file`                | Path to personal repo workflow file     |
| `organization_workflow_file`            | Path to org repo workflow file          |

---

## GitHub Actions Workflow

**File:** `.github/workflows/sync-to-org.yml`

### Trigger

* Runs on every push to the `main` branch

### Steps

1. Checkout full repository history
2. Clear any default GitHub credentials
3. Configure Git username and email
4. Add organization repository as remote
5. Force push `main` → organization repo
6. Skip syncing if `[skip-sync]` found in commit message

### Features

* Prevents infinite sync loops
* Uses secure token from secrets
* Includes robust logging and error handling

---

## Repository Defaults

Both repositories are:

* **Private**
* Have Issues, Projects, and Wiki **enabled**
* Auto-delete merged branches
* Include the **sync-to-org.yml** workflow file

---

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Confirm with `yes` when prompted.

---

## GitHub Token Setup (Detailed)

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**
2. Click **Generate new token (classic)**
3. Select scopes:

   * `repo`
   * `admin:org`
   * `workflow`
4. Copy and securely store the token
5. Paste it into `terraform.tfvars` as `github_token`

Note: Never commit your token to version control.

---

## Troubleshooting

### Common Issues

| Issue                          | Possible Cause                       | Fix                                                   |
| ------------------------------ | ------------------------------------ | ----------------------------------------------------- |
| Authentication error           | Invalid or insufficient token scopes | Ensure token includes `repo`, `admin:org`, `workflow` |
| Organization access denied     | Missing org admin privileges         | Confirm you’re an org admin                           |
| Repository name already exists | Existing repo conflicts              | Change repo names in `terraform.tfvars`               |
| Workflow not running           | Missing `SYNC_TOKEN` secret          | Add secret to personal repo                           |

### Verification

After running Terraform:

* Check both repositories exist (personal + organization)
* Confirm both are **private**
* Verify `.github/workflows/sync-to-org.yml` exists
* Push a commit → confirm workflow syncs correctly

---

## Author

**Adhav Neeraj Sahebrao**
Postgraduate | Cloud Infrastructure & DevOps | Terraform | GCP | GitHub Automation
