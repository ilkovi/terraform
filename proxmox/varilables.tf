
variable "domain_name" { 
  type 		= string
  default 	= "cluster.local"
}

variable "vm_comunt" { 
  type		= number
  default	= 1
}

variable "pve_user" { 
  type		= string
  default	= "root"
}

variable "pve_host" { 
  type		= string
  default	= "proxmox"
}
