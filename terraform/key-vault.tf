data "namep_azure_name" "kv" {
  name     = "main"
  location = azurerm_resource_group.rg.location
  type     = "azurerm_key_vault"
}

resource "azurerm_key_vault" "main" {
  name                = data.namep_azure_name.kv.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name                  = "standard"
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "sp_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "sp_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "sql-pass" {
  name         = "SQL-Admin-Password"
  value        = random_string.sql_pass.result
  key_vault_id = azurerm_key_vault.main.id
  depends_on = [
    azurerm_role_assignment.sp_admin
  ]
}
