resource "azurerm_resource_group" "dev_console_db_rg" {
  name     = "dev-console-db-rg"
  location = var.region
}

data "azurerm_key_vault" "keyvault_postgres" {
  name                = "postgres-db-password"
  resource_group_name = azurerm_resource_group.dev_console_db_rg.name
}

resource "azurerm_key_vault_secret" "postgres_secret" {
  key_vault_id = data.azurerm_key_vault.keyvault_postgres.id
  name         = "postgres-db-password"
  value        = "sensitive"
}

#Create pgsql flexible server
resource "azurerm_postgresql_flexible_server" "dev_console_db" {
  name                   = "dev-console-db"
  resource_group_name    = azurerm_resource_group.dev_console_db_rg.name
  location               = azurerm_resource_group.dev_console_db_rg.location
  version                = var.postgres_version
  administrator_login    = "titans"
  administrator_password = azurerm_key_vault_secret.postgres_secret.value
  zone                   = "1"
  storage_mb             = 32768
  storage_tier           = "P30"

  sku_name = "B_Standard_B1ms"
}

# #Create a sample DB / ignore it.
# resource "azurerm_postgresql_flexible_server_database" "dev_console_database" {
#   name      = "postgres"
#   server_id = azurerm_postgresql_flexible_server.dev_console_db.id
#   collation = "en_US.UTF8"
#   charset   = "UTF8"
# }