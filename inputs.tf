variable "name" {
  description = "Name identifier for servers. Do not include a count (e.g. A1QAAPMADM)"
}

variable "post_count_label" {
  description = "Label that should be appended to the name, after the count. (e.g. the A after 01 in A1QAAPMADM01A)"
  default     = ""
}

variable "location" {
  description = "Azure Location (e.g. North Central US)"
}

variable "resource_group_name" {
  description = "Resource Group Name"
}

 #variable "ad_domain" {
#  description = "The Active Directory Domain to join."
#}

#variable "ad_join_username" {
 # description = "AD Join Account"
#}

#variable "ad_join_password" {
 # description = "AD Join Password"
#}
#
#variable "ad_ou_path" {
 # description = "The AD OU Path to place the VMs into."
#}
#
variable "application_gateway_backend_address_pool_id" {
  description = "AppGW Backend Address Pool ID"
  default     = ""
}

variable "extensions_enabled" {
  description = "Whether to enable the VM extensions. Defaults to TRUE."
  default     = true
}

variable "vm_count" {
  description = "Number of VMs to Provision"
}

variable "os_disk_type" {
  description = "OS Disk Type"
}

variable "os_disk_size" {
  description = "OS Disk Size"
}

variable "storage_uri" {
  description = "Storage URI for Boot Diagnostics"
}

variable "subnet_id" {
  description = "Subnet ID to Assign to NICs"
}

variable "vm_size" {
  description = "VM Size"
}

variable "vm_username" {
  description = "OS Profile Admin Username"
}

variable "vm_password" {
  description = "OS Profile Admin Password"
}

variable "tags" {
  type        = "map"
  description = "Tag Map"
}
