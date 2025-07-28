module "storage_container_ai_transcribe" {
  count = can(var. locations_mapping["location_1"]) ? (var. locations_mapping["location_1"] . storage_container_ai_transcribe_creation ? 1 : 0) : 0
  source = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"
  resource_group_name = azurerm_resource_group.this.name
  location = azurerm_resource_group.this.location
  name = var.locations_mapping ["location_1"].storage_container_ai_transcribe_custom_name != null ? var.locations_mapping["location_1"].storage_container_ai_transcribe_custom
  account_kind = "StorageV2"
  account_tier = "Standard"
  account_replication_type = "LRS"
  blob_properties = {
    versioning_enabled = var.storage_container_ai_transcribe_versioning_enabled
  }
  diagnostic_settings_blob = var.locations_mapping["location_1"].storage_container_logging_enable ? {
    logging = {
      name = var.locations_mapping["location_1"].storage_container_ai_transcribe_custom_name != null ? var.locations_mapping["location_1"]
      log_categories = ["StorageRead", "StorageWrite", "StorageDelete"]
      log_groups = ["allLogs"]
      metric_categories = ["AllMetrics"]
      log_analytics_destination_type = "Dedicated"
      storage_account_resource_id = module.storage_container_logging.id
    }
}: {}  

tags = merge(module. community_label_default. tags,
  {
    "Name" = "${module.community_label_default.id}-${local. az map[var.locations_mapping["location_1"].location]}-${var.storage_container_ai_transcribe_container_name}"
  }
)
    
customer_managed_key = {
  key_vault_resource_id = azurerm_key_vault. regional_storage_account_key. id
  key_name = azurerm_key_vault_key. regional_storage_account_vault_key.name
  # user_assigned_identity_resource_id =
}
containers = [
  {
  name = var. locations_mapping["location_1"]. storage_container_ai_transcribe_custom_name != null ? var. locations_mapping["location_1"]. storage_container_ai_transcribe_cus
  container_access_type = "private"
  }
]
}
