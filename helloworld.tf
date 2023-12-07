resource "azurerm_resource_group" "main" {
  name     = "rg-main"
  location = "francecentral"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018" # Broke students
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-main"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}
resource "azurerm_container_app" "helloworld" {
  name                         = "ca-helloworld"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    min_replicas = 0
    max_replicas = 1
  }

  ingress {
    # TO BE MODIFIED
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}




output "url" {
  value = azurerm_container_app.helloworld.latest_revision_fqdn
}
