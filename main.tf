# use azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

# no register
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
