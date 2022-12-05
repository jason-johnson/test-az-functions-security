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

data "namep_azure_name" "fun" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_function_app"
}

resource "azurerm_linux_function_app" "main" {
  name                = data.namep_azure_name.fun.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  site_config {}
}
