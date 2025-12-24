resource "linode_database_postgresql_v2" "foobar" {
  label = var.label
  engine_id = var.engine_id
  region = var.region
  type = var.type
  root_password = var.root_password
  allow_list = var.allow_list
  cluster_size = var.cluster_size
  ssl_connection = var.ssl_connection
  encrypted = var.encrypted

  updates = {
    duration = var.update_duration
    frequency = var.update_frequency
    hour_of_day = var.update_hour_of_day
    day_of_week = var.update_day_of_week
  }
}