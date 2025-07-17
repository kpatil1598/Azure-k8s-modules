# 
# -------------------------------
# Create custom roles (if provided)
# -------------------------------
resource "azurerm_role_definition" "custom" {
  # Loop over each custom role provided in var.custom_roles
  # Use the role's `name` as the map key
  for_each = {
    for role in var.custom_roles : role.name => role
  }

  # Name of the custom role
  name = each.value.name

  # Scope at which this role is defined (e.g., subscription or resource group)
  scope = each.value.scope

  # Optional: Description of the custom role
  # If not provided, defaults to null
  description = lookup(each.value, "description", null)

  # Define permissions granted by the custom role
  permissions {
    actions     = each.value.actions                    # Allowed actions
    not_actions = lookup(each.value, "not_actions", []) # Optional: actions to explicitly deny
  }

  # List of scopes where this role can be assigned
  assignable_scopes = each.value.assignable_scopes
}

# --------------------------------------------
# Dynamic role lookup (for built-in/custom roles)
# --------------------------------------------
data "azurerm_role_definition" "lookup" {
  # Loop over each assignment in var.assignments
  # Use index-based keys to avoid dynamic key issues
  for_each = {
    for idx, assignment in var.assignments :
    "role-${idx}" => assignment
    if assignment.role_name != null && assignment.role_name != ""
  }

  # Lookup by role name (used for built-in or custom named roles)
  name = each.value.role_name

  # Scope where to look for the role
  scope = each.value.scope
}

# -------------------------------
# Role assignment block
# -------------------------------
resource "azurerm_role_assignment" "this" {
  # Create a unique key for each assignment using index
  for_each = {
    for idx, assignment in var.assignments :
    "assignment-${idx}" => assignment
  }

  # The scope at which the role is being assigned
  scope = each.value.scope

  # Role definition ID to assign (resolved dynamically using coalesce logic below)
  role_definition_id = coalesce(
    # 1. Try to use the role ID from the `data.azurerm_role_definition.lookup` (lookup by index)
    try(data.azurerm_role_definition.lookup["role-${index(var.assignments, each.value)}"].id, null),

    # 2. If not found, check if the role was created as a custom role earlier in this module
    try(azurerm_role_definition.custom[each.value.role_name].role_definition_resource_id, null),

    # 3. Fallback to the directly provided `role_definition_id` in the input
    each.value.role_definition_id
  )

  # The principal (user, group, or service principal) receiving the role
  principal_id = each.value.principal_id
}
