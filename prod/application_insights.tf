# Application Insights: Flume Data Pipeline
resource "azurerm_application_insights" "appi_flume" {
  name                = "appi-lc-flume"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Application Insights: Log Cabin API
resource "azurerm_application_insights" "appi_api" {
  name                = "appi-lc-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}
