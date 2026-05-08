variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "cluster_id" {
  type        = number
  description = "Vultr Object Storage cluster ID for the target region (find via: curl -H 'Authorization: Bearer <api_key>' https://api.vultr.com/v2/object-storage/clusters)"
}

variable "tier_id" {
  type        = number
  description = "Vultr Object Storage performance tier ID (e.g., 1 for standard)"
}

variable "label" {
  type        = string
  description = "Label for the object storage instance"
}
