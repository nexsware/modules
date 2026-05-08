output "id" {
  description = "The ID of the object storage instance"
  value       = vultr_object_storage.this.id
}

output "label" {
  description = "The label of the object storage instance"
  value       = vultr_object_storage.this.label
}

output "region" {
  description = "The region where the object storage instance is deployed"
  value       = vultr_object_storage.this.region
}

output "status" {
  description = "The status of the object storage instance"
  value       = vultr_object_storage.this.status
}
