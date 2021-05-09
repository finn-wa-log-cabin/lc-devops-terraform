# IoT Hub
resource "azurerm_iothub" "iot" {
  location            = azurerm_resource_group.rg.location
  name                = "iot-lc"
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    name     = "F1"
    capacity = "1"
  }
}
