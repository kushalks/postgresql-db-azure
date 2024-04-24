#Resource group
resource "azurerm_resource_group" "dev_console_rg" {
  name     = "dev-console-rg"
  location = var.region
}

#Virtual network
resource "azurerm_virtual_network" "dev_console_vnet" {
  name                = "dev-console-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dev_console_rg.location
  resource_group_name = azurerm_resource_group.dev_console_rg.name
}

#Postgresql DB Subnet
resource "azurerm_subnet" "postgresql_db_subnet" {
  name                 = "postgresql-db-subnet"
  resource_group_name  = azurerm_resource_group.dev_console_rg.name
  virtual_network_name = azurerm_virtual_network.dev_console_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Private DNS Zone
resource "azurerm_private_dns_zone" "postgresql_private_dns_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.dev_console_rg.name
}

#Link private DNS zone to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_dns_vnet" {
  name                  = "postgresql-virtual-network-link"
  resource_group_name   = azurerm_resource_group.dev_console_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.dev_console_vnet.id
}

#Private Endpoint
resource "azurerm_private_endpoint" "dev_console_postgresql_private_endpoint" {
  name                = "dev-console-postgresql-private-endpoint"
  location            = azurerm_resource_group.dev_console_rg.location
  resource_group_name = azurerm_resource_group.dev_console_rg.name
  subnet_id           = azurerm_subnet.postgresql_db_subnet.id

  private_dns_zone_group {
    name                 = "postgresql-private-dns-zone"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgresql_private_dns_zone.id]
  }

  private_service_connection {
    name                           = "pg-privateconnection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.dev_console_db.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}