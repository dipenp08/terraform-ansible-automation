module "network" {
  source   = "./modules/network"
  location = "canadacentral"
}

module "vm" {
  source              = "./modules/vm"
  location            = "canadacentral"
  resource_group_name = module.network.network_rg_name
  subnet_id           = module.network.subnet_id
}
