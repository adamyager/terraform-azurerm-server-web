output "vm_ids" {
  description = "Virtual Machine IDs Created"
  value       = "${azurerm_virtual_machine.vm.*.id}"
}

output "vm_names" {
  description = "Virtual Machine IDs Created"
  value       = "${azurerm_virtual_machine.vm.*.name}"
}

output "availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value       = "${azurerm_availability_set.avset.*.id}"
}
