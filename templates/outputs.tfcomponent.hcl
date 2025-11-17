# ============================================================================
# Stack Outputs
# ============================================================================

output "deployment_summary" {
  type        = string
  description = "Summary of workspace deployment"
  value       = component.bu_onboarding.deployment_summary
}

output "workspace_ids_map" {
  type        = map(string)
  description = "Map of workspace names to IDs"
  value       = component.bu_onboarding.workspace_ids_map
}

output "workspace_names" {
  type        = list(string)
  description = "List of workspace names created"
  value       = component.bu_onboarding.workspace_names
}

output "workspace_urls" {
  type        = list(string)
  description = "List of workspace URLs"
  value       = component.bu_onboarding.workspace_urls
}

output "variable_set_ids_map" {
  type        = map(string)
  description = "Map of variable set names to IDs"
  value       = component.bu_onboarding.variable_set_ids_map
}

output "variable_set_names" {
  type        = list(string)
  description = "List of variable set names created"
  value       = component.bu_onboarding.variable_set_names
}
