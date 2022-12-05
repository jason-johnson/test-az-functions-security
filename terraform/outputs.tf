output "rg_name" {
  description = "Name of project resource group"
  value       = azurerm_resource_group.rg.name
}

output "sa_name" {
  description = "Name of project storage account"
  value       = azurerm_storage_account.main.name
}

output "sp_name" {
  description = "Name of project service plan"
  value       = azurerm_service_plan.main.name
}

output "fun_name" {
  description = "Name of project azure function app"
  value       = azurerm_linux_function_app.main.name
}