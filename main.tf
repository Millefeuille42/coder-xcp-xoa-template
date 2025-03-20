terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
    }
    xenorchestra = {
      source = "vatesfr/xenorchestra"
    }
  }
}

provider "xenorchestra" {
  url      = "${var.xoa_secure ? "wss" : "ws"}://${var.xoa_url}"
  token    = var.xoa_token

  insecure = true
}

provider "coder" {}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

data "xenorchestra_pool" "pool" {
  name_label = var.xoa_pool
}

data "xenorchestra_hosts" "pool" {
  pool_id = data.xenorchestra_pool.pool.id

  sort_by = "name_label"
  sort_order = "asc"
}

data "xenorchestra_host" "host" {
  name_label = data.coder_parameter.vm_host.value
}

data "xenorchestra_template" "template" {
  name_label = data.coder_parameter.vm_template.value
}

data "xenorchestra_network" "net" {
  name_label = data.coder_parameter.network_name.value
}

data "xenorchestra_sr" "storage" {
  name_label = data.coder_parameter.sr_name.value
  pool_id = data.xenorchestra_pool.pool.id
}

locals {
  username = data.coder_workspace_owner.me.name
  hostname = data.coder_workspace.me.name
}

resource "coder_agent" "dev" {
  arch = "amd64"
  os   = "linux"
}

resource "coder_app" "code-server" {
  count         = var.code_server ? 1 : 0
  agent_id     = coder_agent.dev.id
  slug         = "code-server"
  display_name = "code-server"
  url          = "http://localhost:13337/?folder=/home/${local.username}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

# Generate SSH key for VM
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "xenorchestra_vm" "coder_vm" {
  name_label = "coder-${data.coder_workspace.me.id}-${local.username}"
  template   = data.xenorchestra_template.template.id
  cpus       = data.coder_parameter.vm_cpus.value
  memory_max = data.coder_parameter.vm_memory.value * 1024 * 1024 * 1024
  power_state = data.coder_workspace.me.start_count > 0 ? "Running" : "Halted"

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id = data.xenorchestra_sr.storage.id
    name_label = "DISK-coder-${data.coder_workspace.me.id}-${local.username}"
    size  = data.coder_parameter.vm_disk_size.value * 1024 * 1024 * 1024
  }

  tags = [
    "coder",
    data.coder_parameter.vm_template.value,
    data.coder_workspace.me.id,
    local.username,
    local.hostname
  ]

  cloud_config = templatefile("cloud-config.yaml.tftpl", {
    username          = local.username
    hostname          = local.hostname
    ssh_key           = tls_private_key.rsa_4096.public_key_openssh
    coder_agent_token = coder_agent.dev.token
    code_server_setup = var.code_server
    init_script       = base64encode(coder_agent.dev.init_script)
    extra_packages    = var.extra_packages
    tpl_setup_script = base64encode(var.user_setup_script)
    user_setup_script = base64encode(data.coder_parameter.user_setup_script.value)
    user_packages = jsondecode(data.coder_parameter.extra_packages.value)
  })
}

resource "coder_metadata" "vm_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = xenorchestra_vm.coder_vm.id

  item {
    key   = "VM ID"
    value = "[${xenorchestra_vm.coder_vm.id}](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/vms/${xenorchestra_vm.coder_vm.id}/general)" 
  }
  item {
    key   = "vCPUs"
    value = data.coder_parameter.vm_cpus.value
  }
  item {
    key   = "Memory"
    value = data.coder_parameter.vm_memory.value * 1024 * 1024 * 1024
  }
  item {
    key   = "Disk"
    value = data.coder_parameter.vm_disk_size.value * 1024 * 1024 * 1024
  }
  item {
    key   = "Host"
    value = "[${data.xenorchestra_host.host.id}](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/hosts/${data.xenorchestra_host.host.id}/general)"
  }
  item {
    key   = "Network"
    value = "[${data.xenorchestra_network.net.id}](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/hosts/${data.xenorchestra_host.host.id}/network)"
  }
  item {
    key   = "Disk SR"
    value = "[${data.coder_parameter.sr_name.value}](${var.xoa_secure ? "https" : "http"}://${var.xoa_url}/#/srs/${data.xenorchestra_sr.storage.id}/general)" 
  }
  item {
    key   = "State"
    value = xenorchestra_vm.coder_vm.power_state
  }
  item {
    key   = "Public_key"
    value = tls_private_key.rsa_4096.public_key_openssh
    sensitive = true
  }
}
