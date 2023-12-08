resource "azurerm_subnet" "ca" {
  name                 = "subnet-ca"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/23"]
}

resource "azurerm_container_app_environment" "back" {
  name                       = "cae-back"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id   = azurerm_subnet.ca.id
}

resource "azurerm_container_app" "back" {
  name                         = "ca-back"
  container_app_environment_id = azurerm_container_app_environment.back.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "back"
      image  = "ghcr.io/ndl-2023/back:v0.1.0"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "POSTGRES_HOST"
        value = azurerm_postgresql_flexible_server.db.fqdn
      }
      env {
        name  = "POSTGRES_USER"
        value = azurerm_postgresql_flexible_server.db.administrator_login
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = azurerm_postgresql_flexible_server.db.administrator_password
        # secret_name = "pq-pwd"
      }
      env {
        name  = "POSTGRES_DB"
        value = "ndl"
      }
    }
    min_replicas = 0
    max_replicas = 1
  }

  # secret {
  #   name  = "pg-pwd"
  #   value = azurerm_postgresql_flexible_server.db.administrator_password
  # }

  ingress {
    # TO BE MODIFIED
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}


output "url" {
  value = azurerm_container_app.back.latest_revision_fqdn
}

output "pg_pwd" {
  value     = random_password.pg_pwd.result
  sensitive = true
}
