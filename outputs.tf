# ============================================================================
# Core Outputs - TFC Resources
# ============================================================================

output "organization_name" {
  description = "HCP Terraform organization name"
  value       = var.tfc_organization_name
}

output "business_units" {
  description = "List of business units managed by this module"
  value       = keys(local.tenant)
}

# ============================================================================
# BU Project Outputs (Optimized for publish_output)
# ============================================================================

output "bu_project_ids_map" {
  description = "Map of BU names to Platform project ID (all BU Stacks share Platform_Team project due to Stacks RBAC limitation)"
  value = {
    for bu, config in local.tenant : 
    bu => var.platform_stack_project_id
  }
}

output "bu_project_names_map" {
  description = "Map of BU names to Platform project name (all BU Stacks share Platform_Team project due to Stacks RBAC limitation)"
  value = {
    for bu, config in local.tenant : 
    bu => var.platform_stack_project
  }
}

output "consumer_project_ids_map" {
  description = "Map of BU consumer project IDs (bu_project format)"
  value = {
    for key, proj in tfe_project.consumer :
    key => proj.id
  }
}

# ============================================================================
# Team and Token Outputs
# ============================================================================

output "bu_admin_team_ids_map" {
  description = "Map of BU names to admin team IDs"
  value = {
    for bu, team in tfe_team.bu_admin :
    bu => team.id
  }
}

output "bu_admin_tokens" {
  description = "Map of BU names to admin team tokens (sensitive)"
  value = {
    for bu, token in tfe_team_token.bu_admin :
    bu => token.token
  }
  sensitive = true
}

# ============================================================================
# Workspace/Stack Outputs
# ============================================================================

output "bu_stack_ids_map" {
  description = "Map of BU names to HCP Terraform Stack IDs (if created)"
  value = var.create_hcp_stacks ? {
    for bu, stack in tfe_stack.bu_control :
    bu => stack.id
  } : {}
}

output "bu_stack_names_map" {
  description = "Map of BU names to HCP Terraform Stack names (if created)"
  value = var.create_hcp_stacks ? {
    for bu, stack in tfe_stack.bu_control :
    bu => stack.name
  } : {}
}

output "bu_stack_deployment_names" {
  description = "Map of BU names to their Stack deployment names (populated after first run)"
  value = var.create_hcp_stacks ? {
    for bu, stack in tfe_stack.bu_control :
    bu => try(stack.deployment_names, [])
  } : {}
}

# ============================================================================
# Variable Set Outputs
# ============================================================================

output "bu_variable_set_ids_map" {
  description = "Map of BU names to variable set IDs"
  value = {
    for bu, vs in tfe_variable_set.bu_admin :
    bu => vs.id
  }
}

# ============================================================================
# GitHub Repository Outputs (if created)
# ============================================================================

output "bu_stack_repo_names" {
  description = "Map of BU names to Stack repository names in GitHub"
  value = var.create_bu_repositories ? {
    for bu, repo in github_repository.bu_stack :
    bu => repo.name
  } : {}
}

output "bu_stack_repo_urls" {
  description = "Map of BU names to Stack repository HTML URLs"
  value = var.create_bu_repositories ? {
    for bu, repo in github_repository.bu_stack :
    bu => repo.html_url
  } : {}
}

output "bu_stack_clone_urls" {
  description = "Map of BU names to Stack repository clone URLs (SSH)"
  value = var.create_bu_repositories ? {
    for bu, repo in github_repository.bu_stack :
    bu => repo.ssh_clone_url
  } : {}
}

output "bu_github_team_ids" {
  description = "Map of BU names to GitHub admin team IDs"
  value = var.create_bu_repositories ? {
    for bu, team in github_team.bu_admin :
    bu => team.id
  } : {}
}

# ============================================================================
# Structured Output for Downstream Consumption
# ============================================================================

output "bu_infrastructure" {
  description = "Complete infrastructure mapping per BU (for Stacks publish_output)"
  value = {
    for bu, config in local.tenant : bu => {
      # TFC Resources (NOTE: All BU Stacks share Platform project due to Stacks RBAC limitation)
      organization     = var.tfc_organization_name
      project_id       = var.platform_stack_project_id  # Platform project, not BU-specific
      project_name     = var.platform_stack_project     # Platform project name
      team_id          = tfe_team.bu_admin[bu].id
      variable_set_id  = tfe_variable_set.bu_admin[bu].id
      
      # Stack or Workspace (depending on configuration)
      stack_id         = var.create_hcp_stacks ? tfe_stack.bu_control[bu].id : null
      stack_name       = var.create_hcp_stacks ? tfe_stack.bu_control[bu].name : null
      workspace_id     = null  # Legacy field - no longer used with Stacks
      workspace_name   = null  # Legacy field - no longer used with Stacks
      
      # GitHub Resources (if created)
      github_repo_name = var.create_bu_repositories ? github_repository.bu_stack[bu].name : null
      github_repo_url  = var.create_bu_repositories ? github_repository.bu_stack[bu].html_url : null
      # github_team_id   = var.create_bu_repositories ? github_team.bu_admin[bu].id : null
      
      # Consumer Projects
      consumer_projects = {
        for proj_key, proj in tfe_project.consumer :
        proj_key => {
          id   = proj.id
          name = proj.name
        } if startswith(proj_key, "${bu}_")
      }
    }
  }
}

# ============================================================================
# Deployment Summary
# ============================================================================

output "deployment_summary" {
  description = "Summary of resources created"
  value = {
    business_units_count         = length(local.tenant)
    bu_projects_count            = 0  # BU control projects commented out due to Stacks RBAC limitation
    consumer_projects_count      = length(tfe_project.consumer)
    bu_teams_count               = length(tfe_team.bu_admin)
    bu_stacks_count              = var.create_hcp_stacks ? length(tfe_stack.bu_control) : 0
    bu_workspaces_count          = 0  # Legacy field - no longer used with Stacks
    github_repos_created         = var.create_bu_repositories ? length(github_repository.bu_stack) : 0
    github_teams_created         = var.create_bu_repositories ? length(github_team.bu_admin) : 0
  }
}
