provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_object_storage" "this" {
  cluster_id = var.cluster_id
  tier_id    = var.tier_id
  label      = var.label
}
