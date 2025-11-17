# ============================================================================
# Identity Tokens for OIDC Authentication
# ============================================================================

identity_token "tfe" {
  audience = ["${oidc_audience}"]
}

# ============================================================================
# Upstream Stack Reference
# ============================================================================

upstream_input "platform_stack" {
  type   = "stack"
  source = "app.terraform.io/${organization}/${platform_project}/tfc-platform-stack"
}

# ============================================================================
# Local Values
# ============================================================================

locals {
  # Embedded YAML configuration content
  ${business_unit}_yaml = <<-EOT
${yaml_config}
  EOT
}

# ============================================================================
# Deployment Configurations
# ============================================================================

deployment "dev" {
  inputs = {
    # Organization
    tfc_organization_name = "${organization}"
    
    # Upstream inputs from platform stack
    bu_project_id   = upstream_input.platform_stack.bu_infrastructure_${business_unit}["${business_unit}"].project_id
    bu_admin_token  = upstream_input.platform_stack.bu_admin_tokens_${business_unit}["${business_unit}"]
    
    # YAML configuration
    yaml_config_content = local.${business_unit}_yaml
    
    # VCS integration
    vcs_oauth_token_id = "${vcs_oauth_token_id}"
    
    # BU context
    business_unit = "${business_unit}"
    environment   = "dev"
  }
}

deployment "staging" {
  inputs = {
    # Organization
    tfc_organization_name = "${organization}"
    
    # Upstream inputs from platform stack
    bu_project_id   = upstream_input.platform_stack.bu_infrastructure_${business_unit}["${business_unit}"].project_id
    bu_admin_token  = upstream_input.platform_stack.bu_admin_tokens_${business_unit}["${business_unit}"]
    
    # YAML configuration
    yaml_config_content = local.${business_unit}_yaml
    
    # VCS integration
    vcs_oauth_token_id = "${vcs_oauth_token_id}"
    
    # BU context
    business_unit = "${business_unit}"
    environment   = "staging"
  }
}

deployment "production" {
  inputs = {
    # Organization
    tfc_organization_name = "${organization}"
    
    # Upstream inputs from platform stack
    bu_project_id   = upstream_input.platform_stack.bu_infrastructure_${business_unit}["${business_unit}"].project_id
    bu_admin_token  = upstream_input.platform_stack.bu_admin_tokens_${business_unit}["${business_unit}"]
    
    # YAML configuration
    yaml_config_content = local.${business_unit}_yaml
    
    # VCS integration
    vcs_oauth_token_id = "${vcs_oauth_token_id}"
    
    # BU context
    business_unit = "${business_unit}"
    environment   = "production"
  }
}
