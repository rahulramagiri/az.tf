provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "resource-group" {
  name = "terra-rg-demo"
  location = "Central India"
}

resource "azurerm_virtual_network" "demo-network" {
    name = "tf-demo-network"
    address_space =  ["10.0.0.0/16"]
    location = azurerm_resource_group.resource-group.location
    resource_group_name = azurerm_resource_group.resource-group.name
}

resource "azurerm_subnet" "demo-subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.demo-network.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "demo-nic" {
  name                = "my-nic"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "myVM"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]

  vm_size = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myOSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "myVM"
    admin_username = "adminuser"
    admin_password = "AdminPassword1234!"
  }
  
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent       = true
  }
}