module "s3_bucket_ai_transcribe" {
 count = can(var.regions_mapping["region_1"]) ? (var. regions_mapping["region_1"].s3_bucket_ai_transcribe_creation ? 1 : 0) : 0
 source = "cloudposse/s3-bucket/aws"
 version = "4.2.0"
 enabled = var.regions_mapping["region_1"].s3_bucket_ai_transcribe_creation

 bucket_name = var.regions_mapping["region_1"].s3_bucket_ai_transcribe_custom_name != null ? var.regions_mapping["region_1"]. s3_bucket_ai_transcribe_custom_name :" "${module. community_label_default.id}-${local.az_map[var.regions_mapping ["region_1"]. region]}-${var.s3_bucket_ai_transcribe_bucket_name}"
 s3_object_ownership = "BucketOwnerPreferred"
 acl = "private"
 versioning_enabled = var.s3_bucket_ai_transcribe_versioning_enabled

 logging = var.regions_mapping["region_1"].s3_bucket_logging_enable ? I{
   bucket_name = module.s3_logging_bucket[0].bucket_id
   prefix = var. regions_mapping ["region_1"].s3_bucket_ai_transcribe_custom_name != null ? var. regions_mapping ["region_1"]. s3_bucket_ai_transcribe_custom_name : "${module.community_label_default.id}-${local.az_map[var. regions_mapping ["region_1"]. region]}-${var.s3_bucket_ai_transcribe_bucket_name}"

 source_policy_documents = [data.aws_iam_policy_document.s3_bucket_ai_transcribe[0].json]
 lifecycle_configuration_rules = concat(local. s3_bucket_ai_transcribe_lifecycle_configuration_rules, var. s3_bucket_ai_transcribe_lifecycle_configuration_rules)

 sse_algorithm = var.s3_bucket_ai_transcribe_sse_algorithm
 kms_master_key_arn = var.s3_bucket_ai_transcribe_sse_algorithm == "aws:kms" ? aws_kms_key. regional_bucket_key[0].arn : null

 tags = merge(module.community_label_default.tags,
  {
  "Name" = "${module.community_label_default.id}-${local.az_map[var.regions_mapping["region_1"]. region]}-${var.s3_bucket_ai_transcribe_bucket_name}" 
  }
 )
}

Lifecycle
locals {
  s3_bucket_ai_transcribe_lifecycle_configuration_rules = [
    {
      enabled = false
      id = "rule-abort-incomplete-multipart-uploads"
      abort_incomplete_multipart_upload_days = 10
      filter_and = {}  
      expiration = {}
      noncurrent_version_expiration = {}
      transition = [{}]
      noncurrent_version_transition = [{}]
      },
    ]
 }
}
