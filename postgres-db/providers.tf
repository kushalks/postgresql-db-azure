#different terraform providers configuration

provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      version = ">= 3.85.0"
    }
  }
}