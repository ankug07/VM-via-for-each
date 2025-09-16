# Resource Group
resource "azurerm_resource_group" "rg" {
  for_each = var.rgvar
  name     = each.value.name
  location = each.value.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.vnetvar
  name                = each.value.name
  location            = each.value.rg_location
  resource_group_name = each.value.rg_name
  address_space       = ["10.0.0.0/16"]
}

# Subnets
resource "azurerm_subnet" "subnet" {
  depends_on           = [azurerm_virtual_network.vnet]
  for_each             = var.subnetvar
  name                 = each.value.name
  resource_group_name  = each.value.rg_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.address_prefixes
}

# Public IPs
resource "azurerm_public_ip" "pip" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.pipvar
  name                = each.value.name
  resource_group_name = each.value.rg_name
  location            = each.value.rg_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interfaces
resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.nicvar
  name                = each.value.name
  location            = each.value.rg_location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.nsgvar
  name                = each.value.name
  location            = each.value.rg_location
  resource_group_name = each.value.rg_name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NIC-NSG Association
resource "azurerm_network_interface_security_group_association" "association" {
  for_each                  = var.associationvar
  network_interface_id      = azurerm_network_interface.nic[each.value.nic_name].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_name].id
}

# Linux VMs
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on          = [azurerm_network_interface.nic]
  for_each            = var.vmvar
  name                = each.value.name
  resource_group_name = each.value.rg_name
  location            = each.value.rg_location
  size                = each.value.size
  admin_username      = each.value.username
  admin_password      = each.value.password
  network_interface_ids = [
    azurerm_network_interface.nic[each.value.nic_name].id,
  ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Bastion Host
resource "azurerm_bastion_host" "bastion" {
  for_each            = var.bastionvar
  name                = each.value.bastion_name
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet[each.value.subnet_name].id
    public_ip_address_id = azurerm_public_ip.pip[each.value.pip_name].id
  }
}

# Load Balancer
resource "azurerm_lb" "lb" {
  for_each = var.lbvar
  name                = each.value.name
  location            = each.value.rg_location
  resource_group_name = each.value.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-config"
    public_ip_address_id = azurerm_public_ip.pip[each.value.pip_name].id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  for_each = var.backendpool
  name                = each.value.name
  loadbalancer_id     = azurerm_lb.lb[each.value.lb_name].id
}
resource "azurerm_network_interface_backend_address_pool_association" "nic_assoc_vm1" {
  for_each = var.assoclbvm1
  network_interface_id    = azurerm_network_interface.nic[each.value.nicvar1].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool[each.value.backendpool1].id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_assoc_vm2" {
  for_each = var.assoclbvm2
  network_interface_id    = azurerm_network_interface.nic[each.value.nicvar2].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool[each.value.backendpool1].id
}

# LB Rule & health Probe

resource "azurerm_lb_probe" "probe" {
  for_each = var.probevar
  loadbalancer_id = azurerm_lb.lb[each.value.lb-name].id
  name            = each.value.name
  port            = 22
}

resource "azurerm_lb_rule" "rule" {
  depends_on = [ azurerm_lb_probe.probe ]
  for_each = var.lbrulevar
  name                            = each.value.name
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name = "frontend-config"
  backend_address_pool_ids = azurerm_lb_backend_address_pool.bepool[each.value.back-pool].id
  probe_id                        = azurerm_lb_probe.probe[each.value.probe-name].id
  loadbalancer_id                 = azurerm_lb.lb[each.value.lb-name].id
}