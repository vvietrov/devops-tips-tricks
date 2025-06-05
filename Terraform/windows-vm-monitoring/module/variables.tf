variable "resource_group_name" {
  type        = string
  description = "VMs Resource group name"
}

variable "vm_name" {
  type        = string
  description = "VM name"
}

variable "cpu_load_threshold" {
  type        = number
  description = "CPU load monitoring threshold"
}

variable "ram_usage_threshold" {
  type        = number
  description = "RAM usage percentage monitoring threshold"
}

variable "disk_free_space_threshold" {
  type        = map(any)
  description = "Disk usage percentage monitoring threshold"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "action_group_id" {
  type        = string
  description = "Monitoring Action group ID"
}

variable "create_system_managed_identity" {
  type        = bool
  default     = false
  description = "When set to true, the module will create System-managed identity for the VM"
}
