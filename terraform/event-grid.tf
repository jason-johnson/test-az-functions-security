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
    function_id                       = "${azurerm_linux_function_app.main.id}/functions/event-grid-example"
  }
}

data "namep_azure_name" "eges" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_eventgrid_event_subscription"
}

resource "azurerm_eventgrid_event_subscription" "main" {
  name  = data.namep_azure_name.eges.result
  scope = azurerm_eventgrid_system_topic.main.id
  azure_function_endpoint {
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
    function_id                       = "${azurerm_linux_function_app.main.id}/functions/event-grid-example"
  }
}
