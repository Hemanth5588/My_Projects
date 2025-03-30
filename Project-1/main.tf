# Azure Provider source and version being used
 terraform {
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = ">= 4.0"
     }
   }
 }

#Variable defining
variable "client_id" {}
variable "tenant_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "location" {}
variable "resource_group_name" {}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

 # Create Azure Resource group
resource "azurerm_resource_group" "infra_project1" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "infra_vnet" {
  address_space = ["10.0.0.0/24"]
  location            = azurerm_resource_group.infra_project1.location
  name                = "infra-vnet"
  resource_group_name = azurerm_resource_group.infra_project1.name
}

resource "azurerm_subnet" "infra_subnet" {
  address_prefixes = ["10.0.0.0/25"]
  name                 = "infra-subnet"
  resource_group_name  = azurerm_resource_group.infra_project1.name
  virtual_network_name = azurerm_virtual_network.infra_vnet.name
}


resource "azurerm_public_ip" "infra_publicip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.infra_project1.location
  name                = "infra-publicip"
  resource_group_name = azurerm_resource_group.infra_project1.name
}

resource "azurerm_network_interface" "infra_nic" {
  location            = azurerm_resource_group.infra_project1.location
  name                = "infra-nic"
  resource_group_name = azurerm_resource_group.infra_project1.name
  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.infra_subnet.id
    public_ip_address_id = azurerm_public_ip.infra_publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "infra_vm" {
  admin_username      = "azureuser"
  admin_password = "Password@1234"
  location            = azurerm_resource_group.infra_project1.location
  name                = "infra-vm"
  network_interface_ids = [azurerm_network_interface.infra_nic.id]
  resource_group_name = azurerm_resource_group.infra_project1.name
  size                = "Standard_DS1_v2"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "infra_storage" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.infra_project1.location
  name                     = "infrastorage11"
  resource_group_name      = azurerm_resource_group.infra_project1.name
}

resource "azurerm_mssql_server" "infra_sqlserver" {
  name                         = "infra-sql-server"
  resource_group_name          = azurerm_resource_group.infra_project1.name
  location                     = azurerm_resource_group.infra_project1.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "SecureP@ssw0rd"
}

resource "azurerm_mssql_database" "infra_sqldb" {
  server_id = azurerm_mssql_server.infra_sqlserver.id
  name                = "infra-sql-db"
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  lifecycle {
    prevent_destroy = true
  }
}

