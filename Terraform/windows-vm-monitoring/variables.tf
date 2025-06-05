variable "environment" {
  type        = string
  default     = "dev"
  description = "Name of the environment, where resources will be deployed"
}

variable "vms" {
  description = "List of VM configuration maps"
  type = list(object({
    vm_name                        = string
    resource_group_name            = string
    create_system_managed_identity = optional(bool)
    cpu_load_threshold             = optional(number)
    ram_usage_threshold            = optional(number)
    disk_free_space_threshold      = optional(map(number))
  }))

  default = [
    {
      vm_name                        = "vm-name",
      resource_group_name            = "rg-name",
      create_system_managed_identity = true
      cpu_load_threshold             = 95,
      ram_usage_threshold            = 95,
      disk_free_space_threshold = {
        "C" = 25,
        "D" = 30
      }
    },
    {
      vm_name             = "vm-name-2",
      resource_group_name = "rg-name-2"
    }
  ]
}
