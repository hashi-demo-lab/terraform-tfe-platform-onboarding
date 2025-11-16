# Platform Onboarding - Complete Example

This example demonstrates the full capabilities of the platform-onboarding module with GitHub repository creation, using IT department teams as an example.

## Features

- ✅ Multiple IT teams (platform-engineering, security-ops, cloud-infrastructure)
- ✅ GitHub repository creation for team Stacks
- ✅ Branch protection enabled
- ✅ Seeded Stack configurations in each repo
- ✅ Multiple consumer projects per team
- ✅ Complete YAML configurations with variable sets

## Architecture

```
Platform Stack
  ├─ Component: platform-onboarding
  │  ├─ Creates: 3 team projects
  │  ├─ Creates: 3 GitHub repos (tfc-*-bu-stack)
  │  └─ Seeds: Stack configs in each repo
  │
  └─ Deployments:
     ├─ platform-engineering
     ├─ security-ops
     └─ cloud-infrastructure
```

## Usage

### 1. Configure OIDC

Set up OIDC trust relationship with audience: `platform.onboarding`

**AWS Trust Policy Example**:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/app.terraform.io"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "app.terraform.io:aud": "platform.onboarding"
      },
      "StringLike": {
        "app.terraform.io:sub": "organization:cloudbrokeraz:project:Platform_Team:*"
      }
    }
  }]
}
```

### 2. Create Variable Set

In HCP Terraform, create variable set with:
- `github_token` (ephemeral, sensitive) - GitHub PAT with `repo` + `admin:org` scopes

### 3. Create Stack Configuration

See the complete Stack files in this directory:
- [`variables.tfcomponent.hcl`](variables.tfcomponent.hcl)
- [`providers.tfcomponent.hcl`](providers.tfcomponent.hcl)
- [`components.tfcomponent.hcl`](components.tfcomponent.hcl)
- [`outputs.tfcomponent.hcl`](outputs.tfcomponent.hcl)
- [`deployments.tfdeploy.hcl`](deployments.tfdeploy.hcl)

### 4. Deploy

```bash
# Initialize and validate
terraform stacks providers-lock
terraform stacks validate

# Plan each deployment
terraform stacks plan --deployment=platform-engineering
terraform stacks plan --deployment=security-ops
terraform stacks plan --deployment=cloud-infrastructure

# Apply via HCP Terraform UI
```

## What Gets Created

### TFE Resources (per Team)
- **Teams**: `platform-engineering_admin`, `security-ops_admin`, `cloud-infrastructure_admin`
- **Projects**: `BU_platform-engineering`, `BU_security-ops`, `BU_cloud-infrastructure`
- **Consumer Projects**: Multiple per team (e.g., `BU_platform-engineering__kubernetes-platform`)
- **Workspaces**: Control workspace per team
- **Variable Sets**: With team tokens and project mappings

### GitHub Resources (per Team)
- **Repositories**: `tfc-platform-engineering-bu-stack`, `tfc-security-ops-bu-stack`, `tfc-cloud-infrastructure-bu-stack`
- **Teams**: `platform-engineering-admins`, `security-ops-admins`, `cloud-infrastructure-admins`
- **Branch Protection**: Enabled on `main` branch with PR requirements

### Seeded Files (in each BU repo)
- `README.md` - BU-specific documentation
- `variables.tfcomponent.hcl` - Stack variables
- `providers.tfcomponent.hcl` - TFE provider with OIDC
- `components.tfcomponent.hcl` - Sources bu-onboarding module
- `outputs.tfcomponent.hcl` - Stack outputs
- `deployments.tfdeploy.hcl` - Dev/staging/prod deployments
- `configs/<bu_name>.yaml` - Example workspace configuration
- `.github/workflows/terraform-stacks.yml` - CI/CD workflow

## Verification

After deployment, verify:

1. **Check HCP Terraform Projects**:
   ```
   https://app.terraform.io/app/cloudbrokeraz/projects
   ```
   Should see: BU_platform-engineering, BU_security-ops, BU_cloud-infrastructure

2. **Check GitHub Repositories**:
   ```
   https://github.com/hashi-demo-lab
   ```
   Should see: tfc-platform-engineering-bu-stack, tfc-security-ops-bu-stack, tfc-cloud-infrastructure-bu-stack

3. **Check Seeded Files**:
   ```bash
   gh repo view hashi-demo-lab/tfc-platform-engineering-bu-stack
   ```

4. **Check Stack Outputs**:
   ```bash
   terraform stacks output --deployment=platform-engineering
   ```

## Outputs

```hcl
# Per-team outputs
bu_infrastructure = {
  platform-engineering = {
    organization     = "cloudbrokeraz"
    project_id       = "prj-xxxxx"
    project_name     = "BU_platform-engineering"
    team_id          = "team-xxxxx"
    github_repo_name = "tfc-platform-engineering-bu-stack"
    github_repo_url  = "https://github.com/hashi-demo-lab/tfc-platform-engineering-bu-stack"
    # ... more fields
  }
  # security-ops and cloud-infrastructure similar
}

# Admin tokens (sensitive)
bu_admin_tokens = {
  platform-engineering   = "xxxxx.atlasv1.xxxxx"
  security-ops          = "xxxxx.atlasv1.xxxxx"
  cloud-infrastructure  = "xxxxx.atlasv1.xxxxx"
}

# GitHub repositories
bu_stack_repo_names = {
  platform-engineering   = "tfc-platform-engineering-bu-stack"
  security-ops          = "tfc-security-ops-bu-stack"
  cloud-infrastructure  = "tfc-cloud-infrastructure-bu-stack"
}
```

## Published Outputs

These outputs are automatically published for team Stacks to consume:

```hcl
# In team Stack (e.g., tfc-platform-engineering-bu-stack)
upstream_input "platform_stack" {
  type   = "stack"
  source = "app.terraform.io/cloudbrokeraz/Platform_Team/platform-stack"
}

deployment "dev" {
  inputs = {
    bu_project_id  = upstream_input.platform_stack.bu_project_ids_map["platform-engineering"]
    bu_admin_token = upstream_input.platform_stack.bu_admin_tokens["platform-engineering"]
  }
}
```

## Next Steps

1. **Teams Access Repos**: Team admins can now access their repositories
2. **Deploy Team Stacks**: Each team can deploy their Stack (dev/staging/prod)
3. **Manage Workspaces**: Teams edit YAML configs to add workspaces

## Troubleshooting

### "Repository already exists"
Delete existing repos or change `bu_stack_repo_prefix`/`suffix` in deployments.tfdeploy.hcl

### "Insufficient GitHub permissions"
Ensure GitHub token has `repo` and `admin:org` scopes

### "OIDC authentication failed"
Verify OIDC trust policy includes audience `platform.onboarding`

## Files in This Example

- [`README.md`](README.md) - This file
- [`variables.tfcomponent.hcl`](variables.tfcomponent.hcl) - Stack variables
- [`providers.tfcomponent.hcl`](providers.tfcomponent.hcl) - Provider configs with OIDC
- [`components.tfcomponent.hcl`](components.tfcomponent.hcl) - Component definition
- [`outputs.tfcomponent.hcl`](outputs.tfcomponent.hcl) - Stack outputs
- [`deployments.tfdeploy.hcl`](deployments.tfdeploy.hcl) - 3 team deployments
- `config/platform-engineering.yaml` - Platform Engineering team configuration
- `config/security-ops.yaml` - Security Operations team configuration
- `config/cloud-infrastructure.yaml` - Cloud Infrastructure team configuration
