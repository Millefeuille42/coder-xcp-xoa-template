locals {
  hosts_options = { for host in data.xenorchestra_hosts.pool.hosts : host.name_label => {
    name  = host.name_label
    value = host.name_label
  } }
}

data "coder_parameter" "vm_host" {
  name    = "Host for the VM"
  type    = "string"
  description = <<-EOT
    # Provide the host for the VM
    See the [list](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/home?p=1&s=%24pool%3A${data.xenorchestra_pool.pool.id}&t=host) for options.
    EOT

  dynamic "option" {
    for_each = local.hosts_options

    content {
      name  = option.value.name
      value = option.value.value
    }
  }
  default = var.vm_host
}

data "coder_parameter" "vm_template" {
  name    = "VM Template"
  type    = "string"
  icon    = "/icon/personalize.svg"
  description = <<-EOT
    # Provide the VM image
    See the [registry](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/home?p=1&s=&t=VM-template) for options.
    EOT
  default = var.vm_template
}

data "coder_parameter" "vm_memory" {
  name    = "Memory"
  description    = "VM Memory size in GB"
  type    = "number"
  icon    = "/icon/memory.svg"
  default = var.vm_memory
  mutable = true
  validation {
    min       = 2
    max       = data.xenorchestra_host.host.memory
  }
}

data "coder_parameter" "vm_cpus" {
  name    = "vCPUs"
  description    = "Number of vCPUs"
  type    = "number"
  icon    = "/icon/memory.svg"
  default = var.vm_cpus
  mutable = true
  validation {
    min       = 1
    max       = data.xenorchestra_host.host.cpus["cores"]
  }
}

data "coder_parameter" "vm_disk_size" {
  name = "Disk Size"
  description = "Disk size in GB"
  type    = "number"
  icon    = "/icon/database.svg"
  default     = var.vm_disk_size
  validation {
    min = 10
  }
}

data "coder_parameter" "network_name" {
  name = "Network name"
  description = <<-EOT
    # Provide the network name
    See the [list](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/hosts/${data.xenorchestra_host.host.id}/network) for options.
    EOT
  type    = "string"
  default = var.network_name
  mutable = true
}

data "coder_parameter" "sr_name" {
  name = "SR name"
  description = <<-EOT
    # Provide the storage repository name
    See the [list](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/home?p=1&s=&t=SR) for options.
    EOT
  type    = "string"
  icon    = "/icon/database.svg"
  default = var.sr_name
}

data "coder_parameter" "extra_packages" {
  name = "Extra packages"
  description = "Additional packages to install on the workspace VM (Optional)"
  type        = "list(string)"
  icon = "/icon/widgets.svg"
  default     = jsonencode([])  # Optional: Can be empty
}

data "coder_parameter" "user_setup_script" {
  name = "Setup script"
  description = "User-defined setup script that runs after package installation (Optional)"
  type        = "string"
  icon = "/icon/terminal.svg"
  default     = ""  # Optional: Can be empty
}
