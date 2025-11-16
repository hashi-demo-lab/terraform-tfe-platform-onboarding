# ============================================================================
# Consumer Projects (BU-specific application/workload projects)
# ============================================================================

resource "tfe_project" "consumer" {
  for_each = local.bu_projects

  # Use shortened name to stay within 40 character limit
  # Format: {bu_short}_{project_name}
  # Example: plat-eng_kubernetes-platform (30 chars)
  name         = each.value.project_name_short
  organization = var.tfc_organization_name
  description  = try(each.value.project_description, "${each.value.bu} ${each.value.project_key} project")
}

# ============================================================================
# Consumer Project Team Access
# ============================================================================

resource "tfe_team_project_access" "consumer_admin" {
  for_each = local.bu_projects

  access     = "admin"
  project_id = tfe_project.consumer[each.key].id
  team_id    = tfe_team.bu_admin[each.value.bu].id
}

