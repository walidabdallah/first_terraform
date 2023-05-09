variable "prefix" {
  # Change this to your student-id
  default = "wabdallah"
}

data "azurerm_resource_group" "main" {
  name = "${var.prefix}-resources"
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    studentid   = "${var.prefix}"
    provider    = "terraform"
    environment = "workshop"
  }
}

# Create subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create nic
resource "azurerm_network_interface" "main" {
  name                = "instance-nic1"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    studentid   = "${var.prefix}"
    provider    = "terraform"
    environment = "workshop"
  }
}

# Create VM
resource "azurerm_linux_virtual_machine" "default" {
  name                  = "my-first-instance"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = "Standard_B1s"

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username                  = "azureuser"
  admin_password                  = "S3cur3Me!"
  disable_password_authentication = false

  tags = {
    studentid   = "${var.prefix}"
    provider    = "terraform"
    environment = "workshop"
  }
}