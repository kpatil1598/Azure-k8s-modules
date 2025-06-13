variable "custom_roles" {
  description = <<EOT
List of custom roles to create. Each object should include:
- `name`: Name of the role
- `scope`: Scope at which to define the role
- `assignable_scopes`: List of assignable scopes
- `actions`: List of allowed actions
- `not_actions`: (optional) List of denied actions
- `description`: (optional) Role description
EOT
  type = list(object({
    name              = string
    scope             = string
    assignable_scopes = list(string)
    actions           = list(string)
    not_actions       = optional(list(string), [])
    description       = optional(string)
  }))
  default = []
}

variable "assignments" {
  description = <<EOT
List of role assignments. Each object should include:
- `scope`: Resource scope
- `principal_id`: Object ID of principal
- `role_name`: Optional, built-in or custom role name
- `role_definition_id`: Optional, full ID (used if no role_name)
EOT
  type = list(object({
    scope              = string
    principal_id       = string
    role_name          = optional(string)
    role_definition_id = optional(string)
  }))
}
