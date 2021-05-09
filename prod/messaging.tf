# Event Grid System Topic
resource "azurerm_eventgrid_system_topic" "evgt" {
  location               = azurerm_resource_group.rg.location
  name                   = "evgt-lc"
  resource_group_name    = azurerm_resource_group.rg.name
  source_arm_resource_id = azurerm_iothub.iot.id
  topic_type             = "Microsoft.Devices.IoTHubs"
}

# Event Grid Subscription for IoT Device Telemetry
resource "azurerm_eventgrid_event_subscription" "device_telemetry" {
  included_event_types = ["Microsoft.Devices.DeviceTelemetry"]
  name                 = "DeviceTelemetry"
  scope                = azurerm_iothub.iot.id
  azure_function_endpoint {
    function_id                       = "${azurerm_function_app.func_flume.id}/functions/InsertTelemetry"
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }
  storage_blob_dead_letter_destination {
    storage_account_id          = azurerm_storage_account.st.id
    storage_blob_container_name = azurerm_storage_container.iot_dlq.name
  }
}
