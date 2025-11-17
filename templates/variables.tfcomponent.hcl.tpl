# ============================================================================
# Stack Input Variables
# ============================================================================

variable "tfc_organization_name" {
  type        = string
  description = "HCP Terraform organization name"
}

variable "bu_project_id" {
  type        = string
  description = "BU control project ID from platform stack"
}

variable "bu_admin_token" {
  type        = string
  description = "BU admin team token from platform stack"
  ephemeral   = true
  sensitive   = true
}

variable "vcs_oauth_token_id" {
  type        = string
  description = "HCP Terraform VCS OAuth token ID for GitHub integration"
}

variable "yaml_config_content" {
  type        = string
  description = "YAML configuration content for workspace definitions"
}

variable "business_unit" {
  type        = string
  description = "Business unit name"
  default     = "${business_unit}"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, production)"
}
