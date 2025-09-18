#!/bin/bash
set -euo pipefail

# -------- CONFIG --------
RESOURCE_GROUP="$1"
STORAGE_ACCOUNT="$2"
CONTAINER="$3"
BLOB_NAME="$4"
EXPIRY_MINUTES="${5:-60}"

# -------- LOGIN & VARIABLES --------
ACCOUNT_KEY=$(az storage account keys list \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[0].value" -o tsv)

EXPIRY=$(date -u -d "+$EXPIRY_MINUTES minutes" '+%Y-%m-%dT%H:%MZ')

# -------- GENERATE SAS --------
SAS_TOKEN=$(az storage blob generate-sas \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER" \
  --name "$BLOB_NAME" \
  --permissions r \
  --expiry "$EXPIRY" \
  --https-only \
  --account-key "$ACCOUNT_KEY" \
  -o tsv)

echo "sas_token=$SAS_TOKEN" > sas_output.env
