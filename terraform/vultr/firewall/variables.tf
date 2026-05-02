variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "description" {
  type        = string
  description = "Description for the firewall group"
  default     = "firewall"
}

variable "inbound_rules" {
  description = "List of inbound firewall rules"
  type = list(object({
    label    = string
    protocol = string          # tcp | udp | icmp | gre | esp | ah
    network  = string          # CIDR, e.g., 0.0.0.0/0 or 10.0.0.0/24
    port     = optional(string, "")   # single port or range, e.g., "443" or "8000:9000"
    ip_type  = optional(string, "v4") # v4 | v6
  }))
  default = []
}
