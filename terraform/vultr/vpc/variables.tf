variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Vultr region slug (e.g., jnb for Johannesburg)"
}

variable "description" {
  type        = string
  description = "Human-readable label for the VPC"
  default     = "Virtual Private Cloud for Nexware"
}

variable "ip_block" {
  type        = string
  description = "The IPv4 network address for the VPC subnet (e.g., 10.0.0.0). Must be unique across all VPCs in the account."
}

variable "prefix_length" {
  type        = number
  description = "Subnet prefix length (e.g., 24 for /24)"
  default     = 24
}
