# Platform Onboarding - Basic Example

This example demonstrates the minimal configuration required to use the platform-onboarding module.

## Features

- Creates single BU infrastructure (finance)
- No GitHub repository creation
- Minimal required inputs

## Usage

This example is meant to be used with Terraform Stacks. Create a Stack with these files:

### 1. Create `components.tfcomponent.hcl`

```hcl
component "platform_onboarding" {
  source  = "app.terraform.io/cloudbrokeraz/platform-onboarding/tfe"
  version = "1.0.0"
  
  inputs = {
    tfc_organization_name = "cloudbrokeraz"
    business_unit         = "finance"  # Filter to single BU
    
    # Disable GitHub features for basic example
    create_bu_repositories = false
  }
  
  providers = {
    tfe = provider.tfe.this
  }
}
```

### 2. Create `config/finance.yaml`

```yaml
business_unit: finance

projects:
  - name: web-app
    description: Web application infrastructure
```

### 3. Deploy

```bash
terraform stacks providers-lock
terraform stacks validate
terraform stacks plan --deployment=basic
terraform stacks apply --deployment=basic
```

## What Gets Created

- ✅ TFE Team: `finance_admin`
- ✅ TFE Team Token
- ✅ TFE Project: `BU_finance`
- ✅ TFE Control Workspace: `finance_workspace_control`
- ✅ TFE Variable Set with team token and project mappings
- ✅ TFE Consumer Project: `BU_finance__web-app`

## Outputs

```hcl
output "bu_project_id" {
  value = component.platform_onboarding.bu_project_ids_map["finance"]
}

output "bu_admin_token" {
  value     = component.platform_onboarding.bu_admin_tokens["finance"]
  sensitive = true
}
```

## Next Steps

- See `complete` example for GitHub repository creation
- See `complete` example for multiple BUs
- Review module README for all available options
