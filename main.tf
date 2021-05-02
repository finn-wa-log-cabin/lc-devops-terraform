terraform {
  required_version = ">= 0.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-lc-prod"
    storage_account_name = "stlc"
    container_name       = "devops"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "rg" {
  location = "australiaeast"
  name     = "rg-lc-prod"
}

# Storage account
resource "azurerm_storage_account" "st" {
  access_tier              = "Hot"
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.rg.location
  name                     = "stlc"
  resource_group_name      = azurerm_resource_group.rg.name
}

# Storage containers
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

# App Service plan
resource "azurerm_app_service_plan" "plan" {
  kind                = "linux"
  location            = azurerm_resource_group.rg.location
  name                = "plan-lc"
  reserved            = true
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    size = "B1"
    tier = "Basic"
  }
}

# Function App: Flume Data Pipeline
resource "azurerm_function_app" "func_flume" {
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  location                   = azurerm_resource_group.rg.location
  name                       = "func-lc-flume"
  os_type                    = "linux"
  resource_group_name        = azurerm_resource_group.rg.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key
  storage_account_name       = azurerm_storage_account.st.name
  version                    = "~3"
  site_config {
    always_on = true
  }
}

resource "azurerm_application_insights" "appi_flume" {
  name                = "appi-lc-flume"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# # Function App: Log Cabin API
resource "azurerm_function_app" "func_api" {
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  location                   = azurerm_resource_group.rg.location
  name                       = "func-lc-api"
  os_type                    = "linux"
  resource_group_name        = azurerm_resource_group.rg.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key
  storage_account_name       = azurerm_storage_account.st.name
  version                    = "~3"
  site_config {
    always_on = true
  }
}

resource "azurerm_application_insights" "appi_api" {
  name                = "appi-lc-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

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

# Event Grid System Topic
resource "azurerm_eventgrid_system_topic" "evgt" {
  location               = azurerm_resource_group.rg.location
  name                   = "evgt-lc"
  resource_group_name    = azurerm_resource_group.rg.name
  source_arm_resource_id = azurerm_iothub.iot.id
  topic_type             = "Microsoft.Devices.IoTHubs"
}

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

resource "azuread_application" "ad_app" {
  available_to_other_tenants = true
  display_name               = "Log Cabin"
  reply_urls                 = ["http://localhost:3000/"]
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

resource "azurerm_api_management" "apim" {
  location            = azurerm_resource_group.rg.location
  name                = "log-cabin"
  publisher_email     = "finn.welsford-ackroyd@pm.me"
  publisher_name      = "Log Cabin"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Consumption_0"
}
