# ============================================================================
# Required Providers
# ============================================================================

required_providers {
  tfe = {
    source  = "hashicorp/tfe"
    version = "~> 0.60"
  }
}

# ============================================================================
# TFE Provider Configuration with Team Token
# ============================================================================

provider "tfe" "this" {
  config {
    hostname = "app.terraform.io"
    
    # BU Admin Team Token Authentication
    token = var.bu_admin_token
  }
}
