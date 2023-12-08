resource "azurerm_resource_group" "main" {
  name     = "rg-main"
  location = "francecentral"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}
