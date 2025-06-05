data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
}
