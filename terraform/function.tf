data "namep_azure_name" "ws" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_log_analytics_workspace"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = data.namep_azure_name.ws.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "namep_azure_name" "ai" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_application_insights"
}

resource "azurerm_application_insights" "main" {
  name                = data.namep_azure_name.ai.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "Node.JS"
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

  service_plan_id               = azurerm_service_plan.main.id
  storage_account_name          = azurerm_storage_account.main.name
  storage_account_access_key    = azurerm_storage_account.main.primary_access_key
  storage_uses_managed_identity = true

  virtual_network_subnet_id = azurerm_subnet.main-function.id

  site_config {
    application_insights_connection_string = azurerm_application_insights.main.connection_string
    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    health_check_path                      = "/api/http-example"
    application_stack {
      node_version = 18
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "fa" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}