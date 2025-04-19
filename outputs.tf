output "vm_private_ips" {
  value = module.vm.vm_private_ips
}
output "public_ips" {
  value = module.vm.public_ips
}
output "lb_fqdn" {
  value       = "52.237.27.150"
  description = "The FQDN of the Load Balancer"
}
