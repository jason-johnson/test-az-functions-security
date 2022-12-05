data "namep_azure_name" "rg" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_resource_group"
}

resource "azurerm_resource_group" "rg" {
  name     = data.namep_azure_name.rg.result
  location = "West Europe"
}

data "namep_azure_name" "sa" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_storage_account"
}
resource "azurerm_storage_account" "main" {
  name                     = data.namep_azure_name.sa.result
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "namep_azure_name" "sp" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_app_service_plan"
}

resource "azurerm_service_plan" "main" {
  name                = data.namep_azure_name.sp.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}
