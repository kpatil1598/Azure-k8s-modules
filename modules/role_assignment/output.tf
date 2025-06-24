output "role_assignment_ids" {
  value = [for ra in azurerm_role_assignment.this : ra.id]
}

output "custom_role_ids" {
  value = { for k, v in azurerm_role_definition.custom : k => v.id }
}
