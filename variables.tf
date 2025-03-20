variable "xoa_url" {
  description = "Xen Orchestra API hostname"
}

variable "xoa_secure" {
  description = "False to use ws/http, true for wss/https"
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.xoa_secure)
    error_message = "Valid values: true or false."
  }
}

variable "xoa_token" {
  description = "XOA Token"
  sensitive   = true
}

variable "xoa_pool" {
  description = "Pool to use"
}

variable "vm_host" {
  description = "Default host for the workspace VM"
}

variable "vm_template" {
  description = "Template name for the workspace VM"
  default     = "Debian 12"
}

variable "vm_memory" {
  description = "VM memory size in GB"
  default     = 4
  validation {
    condition     = var.vm_memory >= 2
    error_message = "Memory must be at least 2GB."
  }
}

variable "vm_cpus" {
  description = "Number of vCPUs"
  default     = 2
  validation {
    condition     = var.vm_cpus >= 1
    error_message = "vCPU number must be at least 1."
  }
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  default     = 20
  validation {
    condition     = var.vm_disk_size >= 10
    error_message = "Disk size must be at least 10GB."
  }
}

variable "network_name" {
  description = "XCP-ng network name"
  default = "Pool-wide network associated with eth0"
}

variable "sr_name" {
  description = "XCP-ng storage repository name"
  default = "Local storage"
}

variable "extra_packages" {
  description = "Additional packages to install on the workspace VM"
  type        = list(string)
  default     = ["vim", "htop", "build-essential"]
}

variable "user_setup_script" {
  description = "User-defined setup script that runs after package installation"
  type        = string
  default     = ""  # Optional: Can be empty
}

variable "code_server" {
  description = "Install Code Server?"
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.code_server)
    error_message = "Valid values: true or false."
  }
}
