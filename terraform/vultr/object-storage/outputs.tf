output "id" {
  description = "The ID of the object storage instance"
  value       = vultr_object_storage.this.id
}

output "s3_hostname" {
  description = "S3-compatible endpoint hostname"
  value       = vultr_object_storage.this.s3_hostname
}

output "s3_access_key" {
  description = "S3 access key"
  value       = vultr_object_storage.this.s3_access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "S3 secret key"
  value       = vultr_object_storage.this.s3_secret_key
  sensitive   = true
}

output "label" {
  description = "The label of the object storage instance"
  value       = vultr_object_storage.this.label
}
