variable "linode_token" {
  description = "Linode API Token"
  type        = string
  sensitive   = true
}

variable "firewall_label" {
  description = "Label for the Linode firewall"
  type        = string
  default     = "my-firewall"
}

variable "firewall_tags" {
  description = "Tags for the firewall"
  type        = list(string)
  default     = ["production"]
}

variable "inbound_rules" {
  description = "List of inbound firewall rules"
  type = list(object({
    label    = string
    action   = string
    protocol = string
    ports    = string
    ipv4     = list(string)
    ipv6     = optional(list(string), ["::1/128"])
  }))
  default = []
}

variable "outbound_rules" {
  description = "List of outbound firewall rules"
  type = list(object({
    label    = string
    action   = string
    protocol = string
    ports    = string
    ipv4     = list(string)
    ipv6     = optional(list(string), ["::/0"])
  }))
  default = []
}

variable "linodes" {
  description = "List of Linode IDs to attach this firewall to"
  type        = list(number)
  default     = []
}