terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}

provider "namep" {
  slice_string                 = "MOBI DEV"
  default_location             = "westeurope"
  default_nodash_name_format   = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{SHORT_LOC}#{NAME}#{BRANCH}"
  default_resource_name_format = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-BRANCH}"

  extra_tokens = {
    branch = var.branch
  }

  resource_formats = {
    azurerm_eventgrid_system_topic = "egst-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-BRANCH}"
    azurerm_eventgrid_system_topic_event_subscription = "egsts-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-BRANCH}"
  }
}
