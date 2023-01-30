data "namep_azure_name" "egt" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_eventgrid_topic"
}

resource "azurerm_eventgrid_topic" "main" {
  name                = data.namep_azure_name.egt.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}