# -----------------------------------------------------------------------------
# Provider Variables
# -----------------------------------------------------------------------------

variable "linode_token" {
  type        = string
  description = "Linode API token"
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Instance Variables
# -----------------------------------------------------------------------------

variable "label" {
  type        = string
  description = "The label for the Linode instance"
}

variable "region" {
  type        = string
  description = "The region to deploy the Linode in"
}

variable "image" {
  type        = string
  description = "The image to use for the Linode (e.g., linode/ubuntu22.04)"
}

variable "type" {
  type        = string
  description = "The Linode plan type (e.g., g6-standard-1)"
}

variable "root_pass" {
  type        = string
  description = "The root password for the Linode"
  sensitive   = true
  default     = ""
}

variable "authorized_keys" {
  type        = list(string)
  description = "List of SSH public keys to authorize"
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags to assign to the Linode"
  default     = []
}

variable "private_ip" {
  type        = bool
  description = "Whether to enable private networking"
  default     = false
}

# -----------------------------------------------------------------------------
# DNS Variables
# -----------------------------------------------------------------------------

variable "create_dns_record" {
  type        = bool
  description = "Whether to create a DNS record for the instance"
  default     = true
}

variable "domain_id" {
  type        = number
  description = "The ID of the existing Linode domain"
}

variable "domain_name" {
  type        = string
  description = "The name of the existing Linode domain (e.g., example.com)"
}

variable "domain_type" {
  type        = string
  description = "The type of the existing Linode domain"
  default     = "master"
}

variable "subdomain" {
  type        = string
  description = "The subdomain to create (e.g., 'www' for www.example.com)"
}

variable "dns_record_type" {
  type        = string
  description = "The type of DNS record to create (e.g., A, AAAA)"
  default     = "A"
}

variable "dns_ttl_sec" {
  type        = number
  description = "The TTL in seconds for the DNS record"
  default     = 300
}
