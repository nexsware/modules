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

# PostgreSQL provider for managing users and databases
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 2.0.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }
}

provider "postgresql" {
  host            = linode_database_postgresql_v2.foobar.host
  port            = linode_database_postgresql_v2.foobar.port
  username        = linode_database_postgresql_v2.foobar.root_username
  password        = var.root_password
  sslmode         = var.ssl_connection ? "require" : "disable"
  superuser       = false
  connect_timeout = 15
}

# Create additional databases
resource "postgresql_database" "databases" {
  for_each = toset(var.databases)

  name              = each.value
  owner             = linode_database_postgresql_v2.foobar.root_username
  connection_limit  = -1
  allow_connections = true
}

# Create additional database users
resource "postgresql_role" "users" {
  for_each = var.database_users

  name     = each.key
  login    = true
  password = each.value.password
  roles    = each.value.roles
}

# Grant permissions to users on databases
resource "postgresql_grant" "user_database_grants" {
  for_each = {
    for pair in setproduct(keys(var.database_users), var.databases) :
    "${pair[0]}-${pair[1]}" => {
      user     = pair[0]
      database = pair[1]
    }
  }

  database    = each.value.database
  role        = each.value.user
  object_type = "database"
  privileges  = ["CONNECT", "CREATE"]

  depends_on = [
    postgresql_database.databases,
    postgresql_role.users
  ]
}