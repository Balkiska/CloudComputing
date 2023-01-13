variable "sku_database" {
  type    = string
  default = "GP_S_Gen5_2"
}

variable "name" {
  type    = string
  default = "bfresse"
}

variable "subresources_names_sql" {
  type    = list(string)
  default = ["sqlServer"]
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "avd_users" {
  description = "AVD users"
  default = [
    "wow@deletoilleprooutlook.onmicrosoft.com",
    "wow@deletoilleprooutlook.onmicrosoft.com"
  ]
}

variable "aad_group_name" {
  type        = string
  default     = "AVDUsers"
  description = "Azure Active Directory Group for AVD users"
}

variable "allrg" {
  type = map(any)
  default = {
    "first" = {
      name     = "balkis-rgeu"
      location = "West Europe"
    }
  }}

variable "allsa" {
  type = map(any)
  default = {
    "1" = {
      name         = "balkissa1"
      account_tier = "Standard"
    }
    "2" = {
      name         = "balkissa2"
      account_tier = "Premium"
    }
  }
}
variable "allsa2" {
  type = map(any)
  default = {
    "1" = {
      name         = "2balkis1"
      account_tier = "Standard"
    }
    "2" = {
      name         = "2balkis2"
      account_tier = "Premium"
    }
  }
}


variable "vm" {
  type = map(any)
  default = {
    "1" = {
      name                  = "linux"
      network_interface_ids = [azurerm_network_interface.inteface1.id]
      publisher             = "Canonical"
      offer                 = "UbuntuServer"
      sku                   = "16.04-LTS"
      version               = "latest"
    }
  }
}


