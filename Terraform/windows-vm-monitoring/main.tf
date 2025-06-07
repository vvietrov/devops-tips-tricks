locals {
  tags = {
    environment = var.environment
    project     = "test"
    mannagedBy  = "terraform"
  }
}

# One module call - one VM
# A VM sends monitoring information to Azure Monitor, Log Analytics is not used
# In variable "vms" we specify a list of VMs with required and optional parameters
# vm_name and resource_group_name are required, the rest are optional
# A system-managed identity is required for a VM to send monitoring information to Azure Monitor. The module installs it, if it's not enabled.

module "windows_vm_monitoring" {
  for_each = { for vm in var.vms : vm.vm_name => vm }

  source              = "../module"
  resource_group_name = each.value.resource_group_name
  vm_name             = each.value.vm_name

  cpu_load_threshold             = coalesce(each.value.cpu_load_threshold, 90)                  # if no value in variable VMS, then use default value 90
  ram_usage_threshold            = coalesce(each.value.ram_usage_threshold, 90)                 # if no value in variable VMS, then use default value 90
  disk_free_space_threshold      = coalesce(each.value.disk_free_space_threshold, { "C" = 20 }) # if no value in variable VMS, then only disk C will be monitored
  create_system_managed_identity = coalesce(each.value.create_system_managed_identity, false)   # System-managed identity is required for monitoring
  action_group_id                = ""                                                           # resourceID of the action group
  tags                           = local.tags
}
