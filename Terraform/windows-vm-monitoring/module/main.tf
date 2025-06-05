resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                      = "AzureMonitorWindowsAgent"
  virtual_machine_id        = data.azurerm_virtual_machine.this.id
  publisher                 = "Microsoft.Azure.Monitor"
  type                      = "AzureMonitorWindowsAgent"
  type_handler_version      = "1.34"
  automatic_upgrade_enabled = true
}

resource "azurerm_monitor_data_collection_endpoint" "this" {
  name                = "dcre-${var.vm_name}"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.this.location
  kind                = "Windows"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "run_az_cli" {
  count = var.create_system_managed_identity ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
output=$(az vm identity show --name ${var.vm_name} --resource-group ${var.resource_group_name} --query "type=='SystemAssigned'" -o tsv)
echo "output======="
echo $output
if [ "$output" != "true" ]; then az vm identity assign --name ${var.vm_name} --resource-group ${var.resource_group_name} ; fi
EOT
  }
  triggers = {
    vm_name        = var.vm_name
    resource_group = var.resource_group_name
    location       = data.azurerm_resource_group.this.location
  }
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  depends_on = [azurerm_virtual_machine_extension.azure_monitor_agent]

  name                = "vm-dcr-${var.vm_name}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = var.resource_group_name
  kind                = "Windows"

  tags = var.tags

  data_sources {
    performance_counter {
      name                          = "perf-counters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\LogicalDisk(*)\\% Free Space",
      ]
    }
    extension {
      extension_name = "AzureMonitorWindowsAgent"
      name           = "AzureMonitorWindowsAgent"
      streams        = ["Microsoft-InsightsMetrics"]
    }
  }

  destinations {
    azure_monitor_metrics {
      name = "metrics-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["metrics-destination"]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = "dcr-assoc-${var.vm_name}"
  target_resource_id      = data.azurerm_virtual_machine.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Links DCR to VM for metrics collection"
}

resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "cpu-usage-alert-${var.vm_name}"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_virtual_machine.this.id]
  description         = "Alert when CPU usage is high for VM ${var.vm_name}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  enabled             = true

  tags = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_load_threshold
  }

  action {
    action_group_id = var.action_group_id
    webhook_properties = {
      "effective"   = "working-hours"
      "supportedby" = "devops"
    }
  }
}

resource "azurerm_monitor_metric_alert" "ram" {
  name                = "ram-usage-alert-${var.vm_name}"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_virtual_machine.this.id]
  description         = "Alert when RAM is low"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  enabled             = true

  tags = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ram_usage_threshold
  }

  action {
    action_group_id = var.action_group_id
    webhook_properties = {
      "effective"   = "working-hours"
      "supportedby" = "devops"
    }
  }
}


resource "azurerm_monitor_metric_alert" "disk_alerts" {
  for_each = var.disk_free_space_threshold

  name                = "disk-usage-alert-${var.vm_name}-${upper(each.key)}"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_virtual_machine.this.id]
  description         = "Alert when disk usage is high on drive ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Azure.VM.Windows.GuestMetrics"
    metric_name      = "\\LogicalDisk(${upper(each.key)}:)\\% Free Space"
    aggregation      = "Minimum"
    operator         = "LessThan"
    threshold        = each.value
  }

  action {
    action_group_id = var.action_group_id
    webhook_properties = {
      "effective"   = "working-hours"
      "supportedby" = "devops"
    }
  }
}
