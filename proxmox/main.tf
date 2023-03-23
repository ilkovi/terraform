terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.13"
    }
  }
}


provider "proxmox" {
  pm_api_url 		= "https://192.168.0.100:8006/api2/json"
  pm_user		= "terraform-prov@pve"
  pm_tls_insecure 	= true
  pm_log_enable 	= true
  pm_log_file   	= "terraform-plugin-proxmox.log"
  pm_debug      	= true
  pm_log_levels 	= {
    _default    	= "debug"
    _capturelog	 	= ""
  }
}


resource "proxmox_vm_qemu" "cloudinit-test" {
  name		= "cloudinittest"
  target_node	= "proxmox"
  clone		= "ubuntu-cloudinit"

  ciuser	= "ilkovi"
  os_type	= "cloud-init"
  cores		= 2
  sockets	= 1
  memory	= 2560
  scsihw	= "lsi"

  # setup the disk
  disk {
    size	= "32G"
    type	= "scsi"
    storage	= "local-lvm"
    iothread	= 0
    backup	= false
  }

  # Setup the network interface and assign
  network {
    model	= "virtio"
    bridge	= "vmbr0"
  }

  # setup the ip address using cloud-init
  ipconfig0 	= "ip=192.168.0.199/24,gw=192.168.0.1"

  # set default DNS
  nameserver	= "8.8.8.8"


  sshkeys 	= <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9isN/BZIYjizHyXSyMXKvxpEMzr/CHmRtsCSui3JfHZqmgsTOS/cs6H2wPCT03t8/UEyi37FcuBRwPA58u5aCJ6yLd0VSjb2HevZReeVc3nCdk+KeXkcjA7dvZvA4E57whvnZ81GRtEv3XHFLOxhcmA6TpWcRwlG6+I/STt3DE77wqoJZLweLR054tF52gnwnNlpz+GJasXAFiLFXYWNfmGUkPvysxuGJS3q15blwDQ4k83dj9VO5yVF78OgsbUH0lT6dzuX4tBuKGQd2CCOhtu7X0bw7Gnm+p+DV7+RrKfAZuPGIeJNzuloxCdI5LfZO1SbLsGktIei+O5D5l6Sf PC
  EOF

#  provisioner "local-exec" {
    # Leave this here so we know  when to start with Ansible local-exec
#    command = "hostnamectl set-hostname ubuntu1"
#  }

}


