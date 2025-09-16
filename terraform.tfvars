# Resource Groups
rgvar = {
  rgvar1 = {
    name     = "rg-ankit"
    location = "east us"
  }
}

# Virtual Networks
vnetvar = {
  vnetvar1 = {
    name        = "vnet-ankit"
    rg_location = "east us"
    rg_name     = "rg-ankit"
  }
}

# Subnets
subnetvar = {
  subnet-f = {
    name             = "frontend-subnet"
    rg_name          = "rg-ankit"
    vnet_name        = "vnet-ankit"
    address_prefixes = ["10.0.1.0/24"]
  }
  subnet-b = {
    name             = "backend-subnet"
    rg_name          = "rg-ankit"
    vnet_name        = "vnet-ankit"
    address_prefixes = ["10.0.2.0/24"]
  }
  subnet-bastion = {
    name             = "AzureBastionSubnet"
    rg_name          = "rg-ankit"
    vnet_name        = "vnet-ankit"
    address_prefixes = ["10.0.3.0/24"]
  }
}

# Public IPs
pipvar = {
  pipvar1 = {
    name        = "pip-ankit"
    rg_name     = "rg-ankit"
    rg_location = "east us"
  }
  pipvar2 = {
    name        = "pip-for-lb"
    rg_name     = "rg-ankit"
    rg_location = "east us"
  }
}

# Network Interfaces
nicvar = {
  nicvar1 = {
    name        = "nic-ankit"
    rg_name     = "rg-ankit"
    rg_location = "east us"
    subnet_name = "subnet-f"
  }
  nicvar2 = {
    name        = "nic-ankit2"
    rg_name     = "rg-ankit"
    rg_location = "east us"
    subnet_name = "subnet-b"
  }
 }

# Network Security Groups
nsgvar = {
  nsgvar1 = {
    name        = "nsg-ankit"
    rg_name     = "rg-ankit"
    rg_location = "east us"
  }
}

# NIC-NSG Associations
associationvar = {
  associationvar1 = {
    name     = "association-ankit"
    nic_name = "nicvar1" 
    nsg_name = "nsgvar1"
  }
  associationvar2 = {
    name     = "association-ankit2"
    nic_name = "nicvar2"
    nsg_name = "nsgvar1"
  }
}

# Linux Virtual Machines
vmvar = {
  vmvar1 = {
    name        = "vm-ankit-frontend"
    rg_name     = "rg-ankit"
    rg_location = "east us"
    size        = "Standard_B1s"
    username    = "adminuser"
    password    = "Pagal@123"
    nic_name    = "nicvar1"
  }
  vmvar2 = {
    name        = "vm-ankit-backend"
    rg_name     = "rg-ankit"
    rg_location = "east us"
    size        = "Standard_B1s"
    username    = "adminuser"
    password    = "Pagal@1234"
    nic_name    = "nicvar2"
  }
}

# Bastion Host
bastionvar = {
  bastionvar1 = {
    bastion_name = "bastion-ankit"
    location     = "east us"
    rg_name      = "rg-ankit"
    subnet_name  = "subnet-bastion"
    pip_name     = "pipvar1"
  }
}

# Load balancer
lbvar = {
  lbvar1 = {
    name = "lb-ankit"
    rg_name = "rg-ankit"
    rg_location = "east us"
    pip_name = "pipvar2"
  }
}

#Backend Pool
backendpool = {
backendpool1 = {
name = "backend-pool"
lb_name = "lbvar1"
}
}

assoclbvm1 = {
  assoclbvm11 = {
    name = "assocvm1"
    nicvar1 = "nicvar1"
    backendpool1 = "backendpool1"
  }
}

assoclbvm2 = {
  assoclbvm21 = {
    name = "assocvm2"
    nicvar2 = "nicvar2"
    backendpool1 = "backendpool1"
  }
}

probevar = {
  probevar1 = {
    name = "LB-probe"
    lb-name = "lbvar1"
  }
}

lbrulevar = {
  lbrulevar1 = {
    name = "LB-rule"
    lb-name = "lbvar1"
    probe-name = "probevar1"
    back-pool = "backendpool1"
  }
}

