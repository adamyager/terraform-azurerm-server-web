resource "azurerm_availability_set" "avset" {
  name                         = "${var.name}01"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  count                        = "${var.vm_count > 0 ? 1 : 0}"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 5
  managed                      = true
  tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "nic" {
  count               = "${var.vm_count}"
  name                = "${var.name}${format("%02d", count.index+1)}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.name}${format("%02d", count.index+1)}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${var.tags}"
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "backend_pool_association" {
  count                   = "${var.application_gateway_backend_address_pool_id == "" ? 0 : var.vm_count}"
  network_interface_id    = "${element(azurerm_network_interface.nic.*.id, count.index)}"
  ip_configuration_name   = "${var.name}${format("%02d", count.index+1)}"
  backend_address_pool_id = "${var.application_gateway_backend_address_pool_id}"
}

resource "azurerm_virtual_machine" "vm" {
  count                            = "${var.vm_count}"
  name                             = "${var.name}${format("%02d", count.index+1)}${var.post_count_label}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group_name}"
  network_interface_ids            = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.avset.id, count.index}"
  vm_size                          = "${var.vm_size}"
  license_type                     = "Windows_Server"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${var.storage_uri}"
  }

  # Create OS Disk
  storage_os_disk {
    name              = "${var.name}${format("%02d", count.index+1)}${var.post_count_label}C"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.os_disk_type}"
    disk_size_gb      = "${var.os_disk_size}"
  }

  # Create OS Image
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false
  }

  # Create OS and User Profile
  os_profile {
    computer_name  = "${var.name}${format("%02d", count.index+1)}${var.post_count_label}"
    admin_username = "${var.vm_username}"
    admin_password = "${var.vm_password}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine_extension" "NetworkWatcher" {
  name                       = "NetworkWatcher"
  location                   = "${var.location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  count                      = "${var.extensions_enabled ? var.vm_count : 0}"
  settings                   = ""
}

resource "azurerm_virtual_machine_extension" "DependencyAgentWindows" {
  name                       = "DependencyAgentWindows"
  location                   = "${var.location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true
  count                      = "${var.extensions_enabled ? var.vm_count : 0}"
  settings                   = ""
}

#resource "azurerm_virtual_machine_extension" "JoinDomain" {
 # name                       = "JoinDomain"
  #location                   = "${var.location}"
  #resource_group_name        = "${var.resource_group_name}"
  #virtual_machine_name       = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
  #publisher                  = "Microsoft.Compute"
  #type                       = "JsonADDomainExtension"
  #type_handler_version       = "1.3"
  #auto_upgrade_minor_version = true
  #count                      = "${var.extensions_enabled ? var.vm_count : 0}"
  #depends_on                 = ["azurerm_virtual_machine_extension.DependencyAgentWindows", "azurerm_virtual_machine_extension.NetworkWatcher"]

  #settings = <<BASE_SETTINGS
#{
# "Name": "${var.ad_domain}",
 #"User": "${var.ad_join_username}@${var.ad_domain}",
 #"OUPath": "${var.ad_ou_path}",
 #"Restart": "true",
 #"Options": "3"
#}
#BASE_SETTINGS

  #protected_settings = <<PROTECTED_SETTINGS
#{
 #"Password": "${var.ad_join_password}"
#}
#PROTECTED_SETTINGS
#}
