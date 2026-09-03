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

# Host firewall.
#
# Off by default so that adding it changes nothing for instances already built
# through this module. Turn it on and the policy below becomes the whole
# policy — which is the point. Ubuntu images arrive with ufw active and a
# single "allow 22 from anywhere" rule that appears in no Terraform anywhere,
# so a module that only adds rules is editing a firewall it does not own, and
# whatever it forgets to open stays shut with nothing to point at.
variable "ufw_enabled" {
  type        = bool
  description = "Declare the host firewall from this module: reset to a known state, apply the rules below, and enable. Leave false to inherit whatever the image ships."
  default     = false
}

variable "ssh_allow_from" {
  type        = string
  description = "CIDR permitted to reach port 22, e.g. a bastion subnet. Empty means anywhere. When the instance is reached through a bastion over the VPC, this must be the bastion's PRIVATE subnet — its public IP never appears as the source."
  default     = ""
}

variable "public_ports" {
  type        = list(string)
  description = "TCP ports opened to 0.0.0.0/0, e.g. [\"80\", \"443\"] for a host serving the internet. Port 80 is required for certbot's HTTP-01 renewals, not just first issuance."
  default     = []
}

variable "internal_rules" {
  type = list(object({
    port = string
    cidr = string
  }))
  description = "TCP ports opened to a specific CIDR — an app port reachable only from the app subnet, say."
  default     = []
}

variable "disable_password_authentication" {
  type        = bool
  description = <<-EOT
    Turn off SSH password authentication, leaving key auth only.

    Ignored when ssh_key_ids is empty: disabling passwords on a host that has no
    key installed locks it out, and the only way back is the provider's console.
  EOT
  default     = true
}
