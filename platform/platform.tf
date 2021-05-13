// Runtime variables (i.e. not set in tfvars)
variable "az_sub_id" {}
variable "az_client_id" {}
variable "az_client_secret" {}
variable "az_tenant_id" {}
variable "obj_creator" {}
variable "psql_user" {}
variable "psql_password" {}

locals {
    obj_app = "Servian-TestChallenge"
    az_location = "Australia Southeast"
    az_loc_id = "as"
    vm_admin_username = "srvnadmin"
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

resource "tls_private_key" "backendkeypair" {
    algorithm   = "RSA"
    rsa_bits    = 2048
}

resource "tls_private_key" "frontendkeypair" {
    algorithm   = "RSA"
    rsa_bits    = 2048
}

resource "azurerm_resource_group" "rg_shared" {
    name     = "rg-${local.az_loc_id}-servian-shared"
    location = local.az_location

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_resource_group" "rg_backend" {
    name     = "rg-${local.az_loc_id}-servian-backend"
    location = local.az_location

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_resource_group" "rg_frontend" {
    name     = "rg-${local.az_loc_id}-servian-frontend"
    location = local.az_location

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${local.az_loc_id}-servian"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg_shared.location
    resource_group_name = azurerm_resource_group.rg_shared.name

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_subnet" "snet_backend" {
    name                 = "snet-${local.az_loc_id}-servian-backend"
    resource_group_name  = azurerm_resource_group.rg_shared.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/25"]

    # delegation {
    #     name = "delegation"

    #     service_delegation {
    #         name    = "Microsoft.ContainerInstance/containerGroups"
    #         actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    #     }
    # }
}

resource "azurerm_subnet" "snet_frontend" {
    name                 = "snet-${local.az_loc_id}-servian-frontend"
    resource_group_name  = azurerm_resource_group.rg_shared.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.2.0/25"]

    # delegation {
    #     name = "delegation"

    #     service_delegation {
    #         name    = "Microsoft.ContainerInstance/containerGroups"
    #         actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    #     }
    # }
}

resource "azurerm_network_security_group" "nsg_backend" {
    name                = "nsg-${local.az_loc_id}-servian-backend"
    location            = azurerm_resource_group.rg_backend.location
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

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_network_security_group" "nsg_frontend" {
    name                = "nsg-${local.az_loc_id}-servian-frontend"
    location            = azurerm_resource_group.rg_frontend.location
    resource_group_name = azurerm_resource_group.rg_frontend.name

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
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
    location                 = azurerm_resource_group.rg_shared.location
    sku                      = "Basic"
    admin_enabled            = true

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_key_vault" "keyvault" {
    name                        = "kvsrvntestnc81"
    location                    = azurerm_resource_group.rg_shared.location
    resource_group_name         = azurerm_resource_group.rg_shared.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days  = 7
    purge_protection_enabled    = false

    sku_name = "standard"

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id
        secret_permissions = [ "Get", "Set", "List", "Delete", "Purge" ]
    }

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

# resource "azurerm_key_vault_secret" "backend_key" {
#     name         = "backend-private-key"
#     value        = tls_private_key.backendkeypair.private_key_pem
#     key_vault_id = azurerm_key_vault.keyvault.id
# }

resource "azurerm_key_vault_secret" "acr_user" {
    name         = "container-registry-user"
    value        = azurerm_container_registry.acr.admin_username
    key_vault_id = azurerm_key_vault.keyvault.id

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_key_vault_secret" "acr_password" {
    name         = "container-registry-password"
    value        = azurerm_container_registry.acr.admin_password
    key_vault_id = azurerm_key_vault.keyvault.id

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_key_vault_secret" "frontend_key" {
    name         = "frontend-private-key"
    value        = tls_private_key.frontendkeypair.private_key_pem
    key_vault_id = azurerm_key_vault.keyvault.id

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_key_vault_secret" "db_user" {
    name         = "psql-user"
    value        = var.psql_user
    key_vault_id = azurerm_key_vault.keyvault.id

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_key_vault_secret" "db_pass" {
    name         = "psql-user-password"
    value        = var.psql_password
    key_vault_id = azurerm_key_vault.keyvault.id

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_postgresql_server" "postgres" {
    name                = "psql-${local.az_loc_id}-servian-db"
    location            = azurerm_resource_group.rg_backend.location
    resource_group_name = azurerm_resource_group.rg_backend.name

    administrator_login          = var.psql_user
    administrator_login_password = var.psql_password

    sku_name   = "GP_Gen5_2"
    version    = "11"
    storage_mb = 5120

    backup_retention_days        = 7
    geo_redundant_backup_enabled = false

    public_network_access_enabled    = false
    ssl_enforcement_enabled          = true
    ssl_minimal_tls_version_enforced = "TLS1_2"

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

resource "azurerm_kubernetes_cluster" "aks" {
    name                    = "aks-${local.az_loc_id}-servian-app"
    location                = azurerm_resource_group.rg_frontend.location
    resource_group_name     = azurerm_resource_group.rg_frontend.name
    dns_prefix = "srvnfrontend01"

    default_node_pool {
        name            = "default"
        node_count      = 2
        vm_size         = "Standard_B2s"
        vnet_subnet_id  = azurerm_subnet.snet_frontend.id
    }

    role_based_access_control {
        enabled = true
    }

    identity {
        type = "SystemAssigned"
    }

    linux_profile {
        admin_username = local.vm_admin_username

        ssh_key {
            key_data = tls_private_key.frontendkeypair.public_key_openssh
        }
    }

    network_profile {
        network_plugin      = "azure"
        load_balancer_sku   = "Standard"
        docker_bridge_cidr = "192.167.0.1/16"
        dns_service_ip     = "192.168.1.1"
        service_cidr       = "192.168.0.0/16"
        #pod_cidr           = "172.16.0.0/22"
    }

    tags = {
        Creator = var.obj_creator
        Application = local.obj_app
    }
}

output "container_registry_user" {
    value = azurerm_container_registry.acr.admin_username
}

output "container_registry_password" {
    value = azurerm_container_registry.acr.admin_password
}