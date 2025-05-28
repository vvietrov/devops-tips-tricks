# How to pass a complex object to TF module and iterate over it

## Using Key-Value maps

### TF configuration

    variable "vms" {
    description = "Map of project names to configuration"
    type        = map(any)

    default = {
        vm-audit-db-archive-win = {
        vm_name = "vm-01",
        rg_name  = "rg-01",
        cpu_load = 80,
        ram_usage = 80,
        disk_usage = 80
        },
        vm-audit-db-archive-win2 = {
        vm_name = "vm-02",
        rg_name  = "rg-01",
        cpu_load = 80,
        ram_usage = 80,
        disk_usage = 80
        }
    }
    }


### Calling TF module

    module "vm_monitoring" {

    for_each = var.vms                                      # Note iteration format!

    source   = "../../../modules/vm-monitoring"
    rg_name  = each.value.rg_name
    vm_name  = each.value.vm_name

    cpu_load   = each.value.cpu_load
    ram_usage  = each.value.ram_usage
    disk_usage = each.value.disk_usage
    }

## Using a list of Key-Value maps

### TF configuration

    variable "vms" {
    description = "Map of project names to configuration"
    type = list(object({
        rg_name    = string
        vm_name    = string
        cpu_load   = number
        ram_usage  = number
        disk_usage = number
    }))

    default = [{
        vm_name = "vm-01",
        rg_name  = "rg-01",
        cpu_load = 80,
        ram_usage = 80,
        disk_usage = 80
        },
        {
        vm_name = "vm-02",
        rg_name  = "rg-01",
        cpu_load = 80,
        ram_usage = 80,
        disk_usage = 80
        }
    ]
    }


### Calling TF module

    module "vm_monitoring" {
    for_each = { for vm in var.vms : vm.vm_name => vm }             # Note iteration format!

    source   = "../../../modules/vm-monitoring"
    rg_name  = each.value.rg_name
    vm_name  = each.value.vm_name

    cpu_load   = each.value.cpu_load
    ram_usage  = each.value.ram_usage
    disk_usage = each.value.disk_usage
    }


## Using a flexible number of Key-Value pairs and handling default values

### TF configuration

    variable "vms" {
    description = "Map of project names to configuration"
    type = list(object({
        rg_name    = string
        vm_name    = string
        cpu_load   = number
        ram_usage  = number
        disk_usage = number
    }))

    default = [{
        vm_name = "vm-01",
        rg_name  = "rg-01",
        cpu_load = 80,
        ram_usage = 80,
        disk_usage = 80
        },
        {
        vm_name = "vm-02",
        rg_name  = "rg-01"
        }
    ]
    }

### Calling TF module

    module "vm_monitoring" {
    for_each = { for vm in var.vms : vm.vm_name => vm }             # Note iteration format!

    source   = "../../../modules/vm-monitoring"
    rg_name  = each.value.rg_name
    vm_name  = each.value.vm_name

    cpu_load          = lookup(each.value, "cpu_load", 99)          # if no value in variable VMS, then use default 99
    ram_usage         = lookup(each.value, "ram_usage", 99)         # same
    disk_usage        = lookup(each.value, "disk_usage", 99)        # same
    }