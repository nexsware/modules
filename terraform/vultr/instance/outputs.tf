output "id" {
  description = "The ID of the instance"
  value       = vultr_instance.this.id
}

output "ip_address" {
  description = "The public IPv4 address — point your DNS A record here"
  value       = vultr_instance.this.main_ip
}

output "internal_ip" {
  description = "The private/internal IP address within attached VPCs"
  value       = vultr_instance.this.internal_ip
}

output "label" {
  description = "The label of the instance"
  value       = vultr_instance.this.label
}

output "region" {
  description = "The region where the instance is deployed"
  value       = vultr_instance.this.region
}

output "plan" {
  description = "The plan used for the instance"
  value       = vultr_instance.this.plan
}

output "status" {
  description = "The current power status of the instance"
  value       = vultr_instance.this.status
}

output "os_id" {
  description = "The OS ID used for the instance"
  value       = vultr_instance.this.os_id
}
