az storage share-rm list \
  --resource-group example-rg \
  --storage-account eaadcusfs \
  --include-deleted \
  --query "[].{Name:name, Deleted:deleted, DeletedTime:deletedTime}"

az storage share-rm delete \
  --resource-group example-rg \
  --storage-account eaadcusfs \
  --name <share-name> \
  --yes \
  --include-leases

az storage share-rm list \
  --resource-group example-rg \
  --storage-account eaadcusfs \
  --include-deleted
