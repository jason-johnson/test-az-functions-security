terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "namep" {
  slice_string                 = "MOBII TEST"
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
