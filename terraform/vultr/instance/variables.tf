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

variable "vpc_ids" {
  type        = list(string)
  description = "VPC IDs to attach for private networking"
  default     = []
}

variable "private_ip" {
  type        = string
  description = "Static private IP to assign to the VPC interface (e.g., 10.0.0.129). Must be within instance_subnet. Leave empty to use Vultr auto-assigned IP."
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC this instance is deployed into (e.g., 10.0.0.0/24)"
  default     = "10.0.0.0/24"
}

variable "instance_subnet" {
  type        = string
  description = "CIDR of the subnet within the VPC where this instance is placed (e.g., 10.0.0.128/26 for bastion, 10.0.0.0/26 for app)"
  default     = ""
}

variable "db_subnet" {
  type        = string
  description = "CIDR of the database subnet — a route is added so this instance can reach the database (e.g., 10.0.0.64/26). Leave empty to skip."
  default     = ""
}

variable "user_data" {
  type        = string
  description = "Optional shell script to run on first boot after network setup. Leave empty for none."
  default     = ""
}
