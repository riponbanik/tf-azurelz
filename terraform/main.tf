# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.54.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# You can use the azurerm_client_config data resource to dynamically
# extract connection settings from the provider configuration.

data "azurerm_client_config" "core" {}

# Call the caf-enterprise-scale module directly from the Terraform Registry
# pinning to the latest version

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.2.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = "australiaeast"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
    
    
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = "${var.root_id}"
  root_name      = "${var.root_name}"
  library_path   = "${path.root}/lib"

  deploy_identity_resources = true
  subscription_id_identity  = "${var.subscription_identity}"

  deploy_corp_landing_zones = true
  deploy_online_landing_zones = true

  custom_landing_zones = {
    "${var.root_id}-corp-prod" = {
      display_name               = "Prod"
      parent_management_group_id = "${var.root_id}-corp"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "custom_corp"
        parameters     = {
        Deny-Resource-Locations = {
            listOfAllowedLocations = ["australiasteast", ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["australiasteast", ]
          }
        }
        access_control = {}
      }
    }
    "${var.root_id}-corp-non-prod" = {
      display_name               = "Non-Prod"
      parent_management_group_id = "${var.root_id}-corp"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "custom_corp"
        parameters = {
        }
        access_control = {}
      }
    }
  }
 
}