locals {
  sanitized_tags = {
    for k, v in module.community_label_default.tags :
    k => replace(v, "/[^a-zA-Z0-9]/", "")
  }
}

metadata = merge(
  local.sanitized_tags,
  {
    "Name" = "${module.community_label_default.id}-${var.location_short}-${var.storage_account_ai_transcribe_container_name}"
  }
)
