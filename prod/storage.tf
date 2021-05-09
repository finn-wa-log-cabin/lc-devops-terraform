# Storage Account
resource "azurerm_storage_account" "st" {
  access_tier              = "Hot"
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.rg.location
  name                     = "stlc"
  resource_group_name      = azurerm_resource_group.rg.name
}

# Storage Containers
resource "azurerm_storage_container" "devops" {
  name                 = "devops"
  storage_account_name = azurerm_storage_account.st.name
}
resource "azurerm_storage_container" "iot_dlq" {
  name                 = "iot-dlq"
  storage_account_name = azurerm_storage_account.st.name
}

# Tables
resource "azurerm_storage_table" "user" {
  name                 = "User"
  storage_account_name = azurerm_storage_account.st.name
}
resource "azurerm_storage_table" "device" {
  name                 = "Device"
  storage_account_name = azurerm_storage_account.st.name
}
resource "azurerm_storage_table" "device_telemetry" {
  name                 = "DeviceTelemetry"
  storage_account_name = azurerm_storage_account.st.name
}
resource "azurerm_storage_table" "summary" {
  name                 = "Summary"
  storage_account_name = azurerm_storage_account.st.name
}

# Queues
resource "azurerm_storage_queue" "summary_requests" {
  name                 = "summary-requests"
  storage_account_name = azurerm_storage_account.st.name
}
resource "azurerm_storage_queue" "summary_requests_poison" {
  name                 = "summary-requests-poison"
  storage_account_name = azurerm_storage_account.st.name
}
