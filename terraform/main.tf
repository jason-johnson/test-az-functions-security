terraform {
  backend "azurerm" { }
}

provider "namep" {
  slice_string     = "MOBI TEST"
  default_location = "westeurope"
  default_nodash_name_format = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{SHORT_LOC}#{NAME}"
  default_resource_name_format = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}"
}
