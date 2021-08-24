# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.68.0" # was 2.46.1
    }
  }
  backend "azurerm" {
    resource_group_name  = "TerraformState_CloudShell"
    storage_account_name = "tfstatecloudshell2021"
    container_name       = "tfstate"
    key                  = "vWAN_No_AzFW.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivity_subscription_id
  features {}
}

# Run this in the CLI once prior to Terraform commands to grab the storage account key and apply to the $ACCOUNT_KEY environment variable in the Azure CLI
/*
ACCOUNT_KEY=$(az storage account keys list --resource-group "TerraformState_CloudShell" --account-name "tfstatecloudshell2021" --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
*/
