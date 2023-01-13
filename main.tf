

#version de terraform

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.38.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
#création du ressource group en europte de l'ouest
resource "azurerm_resource_group" "bfresse" {
  name     = var.bfresse
  location = "West Europe"
}

#Déployer un Keyvault avec tous les droits secret au groupe "group-etudiants".


resource "azurerm_storage_account" "storage" {
  name                     = "${var.name}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

sku_name = "standard"
#network_acls {
# bypass         = "AzureServices"
# default_action = "Deny"
# ip_rules       = ["176.183.218.111"]
# }
access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover"
  ]
}

# pour utiliser la keyvault
resource "azurerm_key_vault_secret" "mdp" {
  name         = "${var.name}-pass"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
}

#Déployer un MSSQL_Server avec une règle réseau autorisant votre IP Public et la mienne (82.123.113.93)
resource "azurerm_mssql_server" "sql" {
  name                         = "${var.name}-sql"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "iuhgsiuhsugb"
  administrator_login_password = random_password.password.result
  minimum_tls_version          = "1.2"

  #   azuread_administrator {
  #     login_username = "AzureAD Admin"
  #     object_id      = data.azurerm_client_config.current.object_id "94fbd4fb-3a48-4ff3-b821-4bdbc488181b"
  #   }
}

resource "azurerm_mysql_firewall_rule" "test" {
  name                = "test"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "82.123.113.93"
}

#Déployer une base de données sur votre SQL Server:
resource "azurerm_sql_database" "test" {
  name                = "test"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  edition             = "GeneralPurpose"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb         = 4


  sku {
    name     = "GP_Gen5_4"
    tier     = "GeneralPurpose"
    capacity = 4
    family   = "Gen5"
  }

  storage_autogrow = "Disabled"
  read_scale       = "Disabled"
}

#Clef SSH
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Déployer 1 vnet et 5 subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "subnet" {
  count                = 5
  name                 = "${var.name}-subnet${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]

  #disque
  delegation {
    name = "diskspool"

    service_delegation {
      actions = ["Linux.Network/virtualNetworks/read"]
      name    = "Linux.StoragePool/diskPools"
    }
  }
}

resource "azurerm_disk_pool" "example" {
  name                = "example-disk-pool"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "Basic_B1"
  subnet_id           = azurerm_subnet.example.id
  zones               = ["1"]
}

#Déployer 1 vm Ubuntu en 20.04 LTS sur votre subnet 5 et stocker la clé SSH dans votre keyvault
#DEPLOYER UNE VM (UBUNTU/DEBIAN/WINDOWS SERVER)
#SIZE = Standard_B1ms

resource "azurerm_network_interface" "cartereseauvm" {
  name                = "${var.name}-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myvmippublic.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name}-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "Salut123!Hello123!"
  network_interface_ids = [
    azurerm_network_interface.cartereseauvm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "UbuntuServer 20.04 LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "myvmippublic" {
  name                = "${var.name}-publicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}


#déployer 2 storage accounts, 1 standard, 1 premium, sur le ressource groupe de bonchance

resource "azurerm_storage_account" "sas" {
  for_each                 = var.allsa
  name                     = each.value.name
  resource_group_name      = data.azurerm_resource_group.rbonchance.name
  location                 = data.azurerm_resource_group.rbonchance.location
  account_tier             = each.value.account_tier
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "sas2" {
  for_each                 = var.allsa2
  name                     = each.value.name
  resource_group_name      = var.allrg.first.name
  location                 = var.allrg.first.location
  account_tier             = each.value.account_tier
  account_replication_type = "LRS"
}

resource "azurerm_role_assignement" "givecontributor" {
  scope                = azurerm_resource_group.allrg.first.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.usertest.object_id
}

#log analytics
resource "azurerm_log_analytics_workspace" "bafresse" {
  name                = "${var.name}-loganalytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


#droits contributor
data "azuread_user" "aad_user" {
  for_each            = toset(var.avd_users)
  user_principal_name = format("%s", each.key)
}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

resource "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

resource "azuread_group_member" "aad_group_member" {
  for_each         = data.azuread_user.aad_user
  group_object_id  = azuread_group.aad_group.id
  member_object_id = each.value["id"]
}

resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = azuread_group.aad_group.id
}


#grafana

provider "grafana" {
  url  = "http://grafana.example.com/"
  auth = var.grafana_auth
}

provider "grafana" {
  alias = "base"
  url   = "http://grafana.example.com/"
  auth  = var.grafana_auth
}

resource "grafana_organization" "my_org" {
  provider = grafana.base
  name     = "my_org"
}

// Step 2: Create resources within the organization
provider "grafana" {
  alias  = "my_org"
  url    = "http://grafana.example.com/"
  auth   = var.grafana_auth
  org_id = grafana_organization.my_org.org_id
}

resource "grafana_folder" "my_folder" {
  provider = grafana.my_org

  title = "Test Folder"
}
provider "grafana" {
  alias         = "cloud"
  cloud_api_key = "my-token"
}

resource "grafana_cloud_stack" "my_stack" {
  provider = grafana.cloud

  name        = "myteststack"
  slug        = "myteststack"
  region_slug = "us"
}

resource "grafana_api_key" "management" {
  provider = grafana.cloud

  cloud_stack_slug = grafana_cloud_stack.my_stack.slug
  name             = "management-key"
  role             = "Admin"
}

// Step 2: Create resources within the stack
provider "grafana" {
  alias = "my_stack"

  url  = grafana_cloud_stack.my_stack.url
  auth = grafana_api_key.management.key
}

backend "azurerm" {
  resource_group_name  = "tfpipeline-rg"
  storage_account_name = "tfpipelinesa"
  container_name       = "terraform"
  key                  = "AMG/Grafana.tfstate"
}

required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 3.27"
  }
  azapi = {
    source  = "Azure/azapi"
    version = "1.0.0"
  }

}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "azapi" {
}
