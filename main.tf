terraform {
  required_version = ">= 0.14.9"
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

# Storage container for terraform state
resource "azurerm_storage_container" "devops" {
  name                 = "devops"
  storage_account_name = azurerm_storage_account.st.name
}

# Used for Key Vault tenant_id
data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "kv" {
  location            = azurerm_resource_group.rg.location
  name                = "kv-lc"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

# Key Vault data source
data "azurerm_key_vault" "kv_data" {
  name                = azurerm_key_vault.kv.name
  resource_group_name = azurerm_key_vault.kv.resource_group_name
}

# Access key for storage account (used for terraform state updates)
data "azurerm_key_vault_secret" "stlc_access_key" {
  name         = "stlc-access-key"
  key_vault_id = data.azurerm_key_vault.kv_data.id
}
