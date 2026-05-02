variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Vultr region slug (e.g., jnb for Johannesburg)"
}

variable "plan" {
  type        = string
  description = "Vultr plan slug (e.g., vhp-2c-4gb-intel)"
  default     = "vhp-2c-4gb-intel"
}

variable "os_id" {
  type        = number
  description = "Vultr OS ID (e.g., 2284 for Ubuntu 24.04 LTS — verify with: vultr os list)"
}

variable "label" {
  type        = string
  description = "Label for the instance"
}

variable "hostname" {
  type        = string
  description = "Hostname — defaults to label if empty"
  default     = ""
}

variable "ssh_key_ids" {
  type        = list(string)
  description = "Vultr SSH key IDs to authorize on the instance"
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags to assign to the instance"
  default     = []
}

variable "enable_ipv6" {
  type        = bool
  description = "Whether to enable IPv6"
  default     = false
}

variable "firewall_group_id" {
  type        = string
  description = "Firewall group ID to attach — leave empty for none"
  default     = ""
}

variable "vpc2_ids" {
  type        = list(string)
  description = "VPC 2.0 IDs to attach for private networking"
  default     = []
}

variable "user_data" {
  type        = string
  description = "Cloud-init user data script (raw string). Leave empty for no user data."
  default     = ""
}
