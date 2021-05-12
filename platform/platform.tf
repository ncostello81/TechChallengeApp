// Runtime variables (i.e. not set in tfvars)
variable "az_sub_id" {}
variable "az_client_id" {}
variable "az_client_secret" {}
variable "az_tenant_id" {}
variable "obj_creator" {}

locals {
    obj_app = "Servian-TestChallenge"
    az_location = "Australia Southeast"
}

provider "azurerm" {
    subscription_id = var.az_sub_id
    client_id       = var.az_client_id
    client_secret   = var.az_client_secret
    tenant_id       = var.az_tenant_id

    features {}
    skip_provider_registration  = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg_shared" {
    name     = "rg-as-servian-shared"
    location = local.az_location
}

resource "azurerm_resource_group" "rg_backend" {
    name     = "rg-as-servian-backend"
    location = local.az_location
}

resource "azurerm_resource_group" "rg_frontend" {
    name     = "rg-as-servian-frontend"
    location = local.az_location
}

resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-as-servian"
    address_space       = ["10.0.0.0/16"]
    location            = local.az_location
    resource_group_name = azurerm_resource_group.rg_shared.name
}

resource "azurerm_subnet" "snet_backend" {
    name                 = "snet-as-servian-backend"
    resource_group_name  = azurerm_resource_group.rg_shared.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/28"]
}

resource "azurerm_subnet" "snet_frontend" {
    name                 = "snet-as-servian-frontend"
    resource_group_name  = azurerm_resource_group.rg_shared.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.2.0/28"]
}

resource "azurerm_network_security_group" "nsg_backend" {
    name                = "nsg-as-servian-backend"
    location            = local.az_location
    resource_group_name = azurerm_resource_group.rg_backend.name

    security_rule {
        name                       = "nsgsr-deny"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_security_group" "nsg_frontend" {
    name                = "nsg-as-servian-frontend"
    location            = local.az_location
    resource_group_name = azurerm_resource_group.rg_frontend.name
}

resource "azurerm_subnet_network_security_group_association" "backend_nw_assoc" {
    subnet_id                 = azurerm_subnet.snet_backend.id
    network_security_group_id = azurerm_network_security_group.nsg_backend.id
}

resource "azurerm_subnet_network_security_group_association" "frontend_nw_assoc" {
    subnet_id                 = azurerm_subnet.snet_frontend.id
    network_security_group_id = azurerm_network_security_group.nsg_frontend.id
}

resource "azurerm_container_registry" "acr" {
    name                     = "acrsrvntestnc81"
    resource_group_name      = azurerm_resource_group.rg_shared.name
    location                 = local.az_location
    sku                      = "Basic"
    admin_enabled            = false
}

resource "azurerm_key_vault" "keyvault" {
    name                        = "kvsrvntestnc81"
    location                    = local.az_location
    resource_group_name         = azurerm_resource_group.rg_shared.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days  = 7
    purge_protection_enabled    = false

    sku_name = "standard"

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id
        secret_permissions = [ "Get", "Set", "List" ]
    }
}

