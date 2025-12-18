variable "linode_token" {
  type        = string
  description = "The API token for Linode"
  sensitive   = true
}

variable "domain_id" {
    description = "The ID of the existing linode domain"
    type        = number
}

variable "domain_name" {
    description = "The name of the existing linode domain"
    type        = string
}

variable "domain_type" {
    description = "The type of the existing linode domain"
    type        = string
}

variable "subdomain" {
    description = "The subdomain to be added to the existing linode domain"
    type        = string
}

variable "target_ip" {
    description = "The target IP address for the subdomain"
    type        = string
}

variable "record_type" {
    description = "The type of the DNS record (e.g., A, CNAME)"
    type        = string
}

variable "ttl_sec" {
    description = "The Time to Live (TTL) for the DNS record"
    type        = number
}

variable "create_dns_record" {
    description = "Whether to create a DNS record for the subdomain"
    type        = bool
    default     = false
}