output "vm_private_ips" {
  value = [for vm in azurerm_linux_virtual_machine.vms : vm.private_ip_address]
}
output "public_ips" {
  value = [for ip in azurerm_public_ip.pips : ip.ip_address]
}
