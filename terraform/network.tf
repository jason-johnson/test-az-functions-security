data "namep_azure_name" "spoke" {
  name = "spoke"
  type = "azurerm_virtual_network"
}

resource "azurerm_virtual_network" "main" {
  name                = data.namep_azure_name.spoke.result
  address_space       = ["10.10.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "main-default" {
  name                                           = "default"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.main.name
  address_prefixes                               = ["10.10.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "main-function" {
  name                                           = "function"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.main.name
  address_prefixes                               = ["10.10.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_security_group" "main-default" {
  name                = data.namep_azure_name.main-default.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-a-spoke1" {
  subnet_id                 = azurerm_subnet.main-default.id
  network_security_group_id = azurerm_network_security_group.main-default.id
}

data "namep_azure_name" "pe_function" {
  name     = "fa"
  type     = "azurerm_private_endpoint"
}

resource "azurerm_private_endpoint" "private_function" {
  name                = data.namep_azure_name.pe_function.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.main-default.id

  private_service_connection {
    name                           = "main-fa"
    private_connection_resource_id = azurerm_linux_function_app.main.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

resource "azurerm_private_dns_zone" "private_function" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

data "namep_azure_name" "function_app_private" {
  name = "private"
  type = "azurerm_function_app"
}

resource "azurerm_private_dns_a_record" "private_function" {
  name                = data.namep_azure_name.function_app_private.result
  zone_name           = azurerm_private_dns_zone.private_function.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 10
  records             = [azurerm_private_endpoint.private_function.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "spoke"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_function.name
  virtual_network_id    = azurerm_virtual_network.main.id
}