#-----------------------------------------------------------------
# Regional / Common
#-----------------------------------------------------------------

variable "region" {
  type    = string
  default = "australiaeast"
}

variable "environment_code" {
  type    = string
  default = "con"
}

variable "region_code" {
  type    = string
  default = "aue"
}

variable "tags" {
  description = "(Optional) Tags for categorization"
  type        = map(any)
  default = {
    BusinessUnit   = "Hotels"
    Company        = "Contoso Dev/Test"
    CostCentre     = "1410.C.50048.0001"
    Owner          = "owner@contoso.com"
    DeploymentType = "Automated"
  }
}

locals { # management network resource group name
  subnetprefix = "${var.environment_code}-${var.region_code}"
}

variable "connectivity_subscription_id" {
  type    = string
  default = "6bb00255-5486-4db1-96ca-5baefc18b0b2"
}

#-----------------------------------------------------------------
# Network based variables
#-----------------------------------------------------------------

variable "Virtual_Network_Resource_Group_Name_suffix" {
  type    = string
  default = "core_network"
}

variable "azurerm_virtual_wan_name_suffix" {
  type    = string
  default = "vwan"
}

variable "Connectivity_AzFWPolicy1_Name_suffix" {
  type    = string
  default = "001"
}


variable "Connectivityddos_plan_id" {
  description = "Resource ID of the DDoS Service Plan"
  type        = string
  default     = ""
}

variable "network_watcher_suffix" {
  type    = string
  default = "001"
}

# Vitual WAN Hubs & Firewall
variable "virtual_wan" {
  description = "(Required) arguments for the hub subnets component"
  type        = map(any)
  default = {
    prod = {
      name_suffix    = "001"
      environment    = "prod"
      region         = "australiaeast"
      region_code    = "aue"
      address_prefix = "10.0.0.0/23"
      sku            = "standard" # Basic and Standard
    }
    non_prod = {
      name_suffix    = "002"
      environment    = "non_prod"
      region         = "australiaeast"
      region_code    = "aue"
      address_prefix = "10.0.2.0/23"
      sku            = "standard" # Basic and Standard
    }
    ss = {
      name_suffix    = "003"
      environment    = "ss" # Shared Services
      region         = "australiaeast"
      region_code    = "aue"
      address_prefix = "10.0.4.0/23"
      sku            = "standard" # Basic and Standard
    }
  }
}

#-----------------------------------------------------------------
# Spoke Virtual Network 01 - Production
#-----------------------------------------------------------------

# Spoke Virtual Network 01
variable "spoke_prod_virtual_network_01" {
  description = "(Required) arguments for the hub vnet component"
  type = object({
    vnet_suffix   = string
    address_space = list(string)
    dns_servers   = list(string)
  })
  default = {
    vnet_suffix   = "prod_spoke_01"
    address_space = ["10.1.0.0/21"]
    dns_servers   = []
  }
}

# Spoke Virtual Network Subnets 01
variable "spoke_subnets_01" {
  description = "(Required) arguments for the hub subnets component"
  type        = map(any)
  default = {
    one = {
      name_suffix                 = "001"
      address_prefixes            = ["10.1.0.0/24"]
      service_endpoints           = []
      network_security_group_name = ""
    }
    two = {
      name_suffix                 = "002"
      address_prefixes            = ["10.1.1.0/24"]
      service_endpoints           = []
      network_security_group_name = ""
    }
  }
}

#-----------------------------------------------------------------
# Spoke Virtual Network 02 - Non-Production
#-----------------------------------------------------------------

# Spoke Virtual Network 02
variable "spoke_nonprod_virtual_network_01" {
  description = "(Required) arguments for the hub vnet component"
  type = object({
    vnet_suffix   = string
    address_space = list(string)
    dns_servers   = list(string)
  })
  default = {
    vnet_suffix   = "nonprod_spoke_01"
    address_space = ["10.1.8.0/21"]
    dns_servers   = []
  }
}

# Spoke Virtual Network Subnets 02
variable "spoke_subnets_02" {
  description = "(Required) arguments for the hub subnets component"
  type        = map(any)
  default = {
    one = {
      name_suffix                 = "001"
      address_prefixes            = ["10.1.8.0/24"]
      service_endpoints           = []
      network_security_group_name = ""
    }
    two = {
      name_suffix                 = "002"
      address_prefixes            = ["10.1.9.0/24"]
      service_endpoints           = []
      network_security_group_name = ""
    }
  }
}

#-----------------------------------------------------------------
# Spoke Virtual Network 03 - Shared Services
#-----------------------------------------------------------------

# Spoke Virtual Network 03
variable "spoke_ss_virtual_network_01" {
  description = "(Required) arguments for the hub vnet component"
  type = object({
    vnet_suffix   = string
    address_space = list(string)
    dns_servers   = list(string)
  })
  default = {
    vnet_suffix   = "ss_spoke_01"
    address_space = ["10.1.16.0/21"]
    dns_servers   = []
  }
}

# Spoke Virtual Network Subnets 03
variable "spoke_subnets_03" {
  description = "(Required) arguments for the hub subnets component"
  type        = map(any)
  default = {
    one = {
      name_suffix                 = "001"
      address_prefixes            = ["10.1.16.0/24"]
      service_endpoints           = []
      network_security_group_name = ""
    }
    two = {
      name_suffix                 = "002"
      address_prefixes            = ["10.1.17.0/24"]
      service_endpoints           = []
      network_security_group_name = ""
    }
  }
}

variable "Connectivity_network_security_group" {
  description = "(Required) arguments for the Network security group to be created"
  type        = map(any)
  default = {
    one = {
      name_suffix            = "001"
      network_security_rules = []
    }
    two = {
      name_suffix            = "002"
      network_security_rules = []
    }
    three = {
      name_suffix            = "003"
      network_security_rules = []
    }

  }
}

# This has the location to Azure firewall mapping required for the route tables
variable "route_afw_map" {
  description = "(Required) Hash map for location names with their Azure firewall ips"
  type        = map(string)
  default = {
    "Firewall1" = "10.54.112.4"
    "Firewall2" = "10.54.113.132"
  }
}