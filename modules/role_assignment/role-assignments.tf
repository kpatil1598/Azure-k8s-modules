# variable "assignments" {
#   type = list(object({
#     scope               = string
#     principal_id        = string
#     role_name           = optional(string)
#     role_definition_id  = optional(string)
#   }))

#   description = "List of role assignments. Use either role_name (for dynamic lookup) or role_definition_id (for static assignment)."
# }

# variable "custom_roles" {
#   type = list(object({
#     name              = string
#     scope             = string
#     description       = optional(string)
#     actions           = list(string)
#     not_actions       = optional(list(string), [])
#     assignable_scopes = list(string)
#   }))

#   default     = []
#   description = "Optional list of custom roles to create."
# }
