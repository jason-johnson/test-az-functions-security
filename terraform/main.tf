terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "namep" {
  slice_string                 = "MOBI TEST"
  default_location             = "westeurope"
  default_nodash_name_format   = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{SHORT_LOC}#{NAME}"
  default_resource_name_format = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}"
}

data "namep_azure_name" "rg" {
  name     = "test"
  location = "westeurope"
  type     = "azurerm_resource_group"
}

resource "azurerm_resource_group" "rg" {
  name     = data.namep_azure_name.rg.result
  location = "West Europe"
}
