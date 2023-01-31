resource "azurerm_service_plan" "main" {
  name                = data.namep_azure_name.sp.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

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

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

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

  sticky_settings {
    app_setting_names = [
      "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET",
    ]
  }
}

resource "azapi_update_resource" "set_forward_proxy" {
  type        = "Microsoft.Web/sites/config@2020-12-01"
  resource_id = "${azurerm_linux_function_app.main.id}/config/web"

  body = jsonencode({
    properties = {
      siteAuthSettingsV2 = {
        httpSettings = {
          requireHttps = true,
          routes = {
            apiPrefix = "/.auth"
          }
          forwardProxy = {
            convention           = "Custom"
            customHostHeaderName = "X-original-host"
          }
        }
      }
    }
  })
}