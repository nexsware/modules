variable "server_name" {
  type        = string
  description = "The domain name for the nginx server_name directive (e.g., nexsware.com)"
}
variable "label" {
  type        = string
  description = "The label for the Linode instance"
}

variable "linode_token" {
  type        = string
  description = "The API token for Linode"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The region to deploy the Linode in"
  default     = "in-maa"
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

variable "stackscript_data" {
  type        = map(string)
  description = "The StackScript data to be used for provisioning"
  default     = {}
}

variable "stackscript_id" {
  type        = number
  description = "The StackScript ID to use for provisioning"
  default     = 0
}

variable "firewall_ids" {
  type        = list(number)
  description = "List of Firewall IDs to attach to the Linode"
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

variable "public_interface" {
  type        = bool
  description = "Whether to create a public interface for the instance"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "The Linode VPC ID to attach the instance to (optional)"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "The Linode Subnet ID to attach the instance to (optional)"
  default     = ""
}