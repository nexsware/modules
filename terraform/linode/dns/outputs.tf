output "record_id" {
    description = "The ID of the DNS record"
    value = try(linode_domain_record.main[0].id, "Record not found")
}

output "record_name" {
    description = "The name of the DNS record"
    value = try(linode_domain_record.main[0].name, "Record not found")
}

output "record_type" {
    description = "The type of the DNS record"
    value = try(linode_domain_record.main[0].record_type, "Record not found")
}

output "record_target" {
    description = "The target of the DNS record"
    value = try(linode_domain_record.main[0].target, "Record not found")
}