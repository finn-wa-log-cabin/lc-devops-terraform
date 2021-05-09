# API Management
resource "azurerm_api_management" "apim" {
  location            = azurerm_resource_group.rg.location
  name                = "log-cabin"
  publisher_email     = "finn.welsford-ackroyd@pm.me"
  publisher_name      = "Log Cabin"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Consumption_0"
}
