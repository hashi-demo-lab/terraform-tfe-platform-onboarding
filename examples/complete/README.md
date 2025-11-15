# Platform Onboarding - Complete Example

This example demonstrates the full capabilities of the platform-onboarding module with GitHub repository creation.

## Features

- ✅ Multiple business units (finance, engineering, sales)
- ✅ GitHub repository creation for BU Stacks
- ✅ Branch protection enabled
- ✅ Seeded Stack configurations in each repo
- ✅ Multiple consumer projects per BU
- ✅ Complete YAML configurations

## Architecture

```
Platform Stack
  ├─ Component: platform-onboarding
  │  ├─ Creates: 3 BU projects
  │  ├─ Creates: 3 GitHub repos (tfc-*-bu-stack)
  │  └─ Seeds: Stack configs in each repo
  │
  └─ Deployments:
     ├─ finance
     ├─ engineering
     └─ sales
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
terraform stacks plan --deployment=finance
terraform stacks plan --deployment=engineering
terraform stacks plan --deployment=sales

# Apply via HCP Terraform UI
```

## What Gets Created

### TFE Resources (per BU)
- **Teams**: `finance_admin`, `engineering_admin`, `sales_admin`
- **Projects**: `BU_finance`, `BU_engineering`, `BU_sales`
- **Consumer Projects**: Multiple per BU (e.g., `BU_finance__payment-gateway`)
- **Workspaces**: Control workspace per BU
- **Variable Sets**: With team tokens and project mappings

### GitHub Resources (per BU)
- **Repositories**: `tfc-finance-bu-stack`, `tfc-engineering-bu-stack`, `tfc-sales-bu-stack`
- **Teams**: `finance-admins`, `engineering-admins`, `sales-admins`
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
   Should see: BU_finance, BU_engineering, BU_sales

2. **Check GitHub Repositories**:
   ```
   https://github.com/hashi-demo-lab
   ```
   Should see: tfc-finance-bu-stack, tfc-engineering-bu-stack, tfc-sales-bu-stack

3. **Check Seeded Files**:
   ```bash
   gh repo view hashi-demo-lab/tfc-finance-bu-stack
   ```

4. **Check Stack Outputs**:
   ```bash
   terraform stacks output --deployment=finance
   ```

## Outputs

```hcl
# Per-BU outputs
bu_infrastructure = {
  finance = {
    organization     = "cloudbrokeraz"
    project_id       = "prj-xxxxx"
    project_name     = "BU_finance"
    team_id          = "team-xxxxx"
    github_repo_name = "tfc-finance-bu-stack"
    github_repo_url  = "https://github.com/hashi-demo-lab/tfc-finance-bu-stack"
    # ... more fields
  }
  # engineering and sales similar
}

# Admin tokens (sensitive)
bu_admin_tokens = {
  finance     = "xxxxx.atlasv1.xxxxx"
  engineering = "xxxxx.atlasv1.xxxxx"
  sales       = "xxxxx.atlasv1.xxxxx"
}

# GitHub repositories
bu_stack_repo_names = {
  finance     = "tfc-finance-bu-stack"
  engineering = "tfc-engineering-bu-stack"
  sales       = "tfc-sales-bu-stack"
}
```

## Published Outputs

These outputs are automatically published for BU Stacks to consume:

```hcl
# In BU Stack (e.g., tfc-finance-bu-stack)
upstream_input "platform_stack" {
  type   = "stack"
  source = "app.terraform.io/cloudbrokeraz/Platform_Team/platform-stack"
}

deployment "dev" {
  inputs = {
    bu_project_id  = upstream_input.platform_stack.bu_project_ids_map["finance"]
    bu_admin_token = upstream_input.platform_stack.bu_admin_tokens["finance"]
  }
}
```

## Next Steps

1. **BU Teams Access Repos**: BU admins can now access their repositories
2. **Deploy BU Stacks**: Each BU can deploy their Stack (dev/staging/prod)
3. **Manage Workspaces**: BU teams edit YAML configs to add workspaces

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
- [`deployments.tfdeploy.hcl`](deployments.tfdeploy.hcl) - 3 BU deployments
- `config/finance.yaml` - Finance BU configuration
- `config/engineering.yaml` - Engineering BU configuration
- `config/sales.yaml` - Sales BU configuration
