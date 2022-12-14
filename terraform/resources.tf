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

data "namep_azure_name" "egst" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_eventgrid_system_topic"
}

resource "azurerm_eventgrid_system_topic" "main" {
  name                   = data.namep_azure_name.egst.result
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  source_arm_resource_id = azurerm_storage_account.main.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  identity {
    type = "SystemAssigned"
  }
}

data "namep_azure_name" "egsts" {
  name     = "funsa"
  location = "westeurope"
  type     = "azurerm_eventgrid_system_topic_event_subscription"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "main" {
  name                = data.namep_azure_name.egsts.result
  system_topic        = azurerm_eventgrid_system_topic.main.name
  resource_group_name = azurerm_resource_group.rg.name

  azure_function_endpoint {
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
    function_id = "${azurerm_linux_function_app.main.id}/functions/event-grid-example"
  }
}
