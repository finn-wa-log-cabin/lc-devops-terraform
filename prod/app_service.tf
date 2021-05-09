# App Service Plan for Function Apps
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

# Function App: Log Cabin API
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
