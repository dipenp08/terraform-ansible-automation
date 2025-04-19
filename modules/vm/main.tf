# Public IPs for each VM (Static)
resource "azurerm_public_ip" "pips" {
  count               = 3
  name                = "pip${count.index + 1}-8445"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Basic"
  lifecycle {
    prevent_destroy = true
  }
}

# Network Interfaces with Public IPs
resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "nic${count.index + 1}-8445"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pips[count.index].id
  }
}

# Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "vms" {
  count               = 3
  name                = "vm${count.index + 1}-8445"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Project        = "CCGC 5502 Automation Project"
    Name           = "dipen.patel"
    ExpirationDate = "2024-12-31"
    Environment    = "Project"
  }
}

# Managed Data Disks
resource "azurerm_managed_disk" "datadisks" {
  count                = 3
  name                 = "datadisk${count.index + 1}-8445"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

# Attach Disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "attach_disks" {
  count              = 3
  managed_disk_id    = azurerm_managed_disk.datadisks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vms[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}
resource "null_resource" "ansible_provisioner" {
  provisioner "local-exec" {
    command = <<EOT
      cd ${path.module}/../../ansible && \
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini dipen8445-playbook.yml
    EOT
  }

  depends_on = [
    azurerm_linux_virtual_machine.vms
  ]
}
