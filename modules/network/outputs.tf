output "network_rg_name" {
  value = azurerm_resource_group.network_rg.name
}
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
