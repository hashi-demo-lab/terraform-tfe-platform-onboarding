# ============================================================================
# BU Onboarding Component
# ============================================================================

component "bu_onboarding" {
  source  = "app.terraform.io/${organization}/bu-onboarding/tfe"
  version = "1.0.1"
  
  inputs = {
    # Organization and project
    tfc_organization_name = var.tfc_organization_name
    bu_project_id         = var.bu_project_id
    
    # YAML Configuration
    yaml_config_content = var.yaml_config_content
    
    # Business unit filter
    business_unit = var.business_unit
    
    # VCS integration
    vcs_oauth_token_id = var.vcs_oauth_token_id
    
    # Environment tagging
    environment = var.environment
  }
  
  providers = {
    tfe = provider.tfe.this
  }
}
