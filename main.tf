provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Azuretestbalu" {
  name     = "Test98"
  location = "West Europe"
}


resource "azurerm_virtual_network" "VNT" {
  name                = "Yall"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Azuretestbalu.location
  resource_group_name = azurerm_resource_group.Azuretestbalu.name
}

resource "azurerm_subnet" "SNT" {
  count                = 2
  name                 = "internalsubnet-${count.index}"
  resource_group_name  = azurerm_resource_group.Azuretestbalu.name
  virtual_network_name = azurerm_virtual_network.VNT.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

resource "azurerm_network_interface" "NETIC" {
  count                = 2  
  name                = "example-nic-${count.index}"
  location            = azurerm_resource_group.Azuretestbalu.location
  resource_group_name = azurerm_resource_group.Azuretestbalu.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SNT[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VMBalu" {
  count                = 2  
  name                = "TerraVM-${count.index}"
  resource_group_name = azurerm_resource_group.Azuretestbalu.name
  location            = azurerm_resource_group.Azuretestbalu.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.NETIC[count.index].id,
  ]

  os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}