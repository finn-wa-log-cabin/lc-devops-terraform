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

resource "azurerm_resource_group" "rg" {
  location = "australiaeast"
  name     = "rg-lc-prod"
}

resource "azuread_application" "ad_app" {
  available_to_other_tenants = false
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
