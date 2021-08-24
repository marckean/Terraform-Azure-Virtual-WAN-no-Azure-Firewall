#-----------------------------------------------------------------
# Network Resources
#-----------------------------------------------------------------
resource "azurerm_resource_group" "Virtual_Network" {
  provider = azurerm.connectivity
  name     = "${var.environment_code}-${var.region_code}-rg-${var.Virtual_Network_Resource_Group_Name_suffix}"
  location = var.region
}

#-----------------------------------------------------------------
# Azure Network Watcher   (Only is deploying into a new blank subscription)
#-----------------------------------------------------------------
/*
When you create or update a virtual network in your subscription,
Network Watcher will be enabled automatically in your Virtual Network's region.
There is no impact to your resources or associated charge for automatically enabling Network Watcher.
https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-create
- deploying it here to control the configuration, forcing custom configuration, instead of automatic configuration

resource "azurerm_network_watcher" "connectivity" {
  name                = "${var.environment_code}-${var.region_code}-anw-${var.network_watcher_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
}
*/
#-----------------------------------------------------------------
# Spoke Virtual Network 01
#-----------------------------------------------------------------

resource "azurerm_virtual_network" "Prod_Virtual_Network_01" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vnt-${var.spoke_prod_virtual_network_01.vnet_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  address_space       = var.spoke_prod_virtual_network_01.address_space
  tags                = var.tags
  dns_servers         = var.spoke_prod_virtual_network_01.dns_servers
}

#-----------------------------------------------------------------
# Spoke Subnets 01
#-----------------------------------------------------------------

resource "azurerm_subnet" "Prod_Virtual_Network_Subnets_01" {
  for_each                                       = var.spoke_subnets_01
  provider                                       = azurerm.connectivity
  name                                           = (each.value.name_suffix != "AzureFirewallSubnet") && (each.value.name_suffix != "AzureBastionSubnet") ? "${local.subnetprefix}-${each.value.name_suffix}" : each.value.name_suffix
  address_prefixes                               = each.value.address_prefixes
  resource_group_name                            = azurerm_resource_group.Virtual_Network.name
  virtual_network_name                           = azurerm_virtual_network.Prod_Virtual_Network_01.name
  service_endpoints                              = each.value.service_endpoints
  enforce_private_link_endpoint_network_policies = true
  #enforce_private_link_service_network_policies = true
  depends_on = [
    azurerm_resource_group.Virtual_Network
  ]
}

#-----------------------------------------------------------------
# Spoke Virtual Network 02
#-----------------------------------------------------------------

resource "azurerm_virtual_network" "NonProd_Virtual_Network_01" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vnt-${var.spoke_nonprod_virtual_network_01.vnet_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  address_space       = var.spoke_nonprod_virtual_network_01.address_space
  tags                = var.tags
  dns_servers         = var.spoke_nonprod_virtual_network_01.dns_servers
}

#-----------------------------------------------------------------
# Spoke Subnets 02
#-----------------------------------------------------------------

resource "azurerm_subnet" "NonProd_Virtual_Network_Subnets_01" {
  for_each                                       = var.spoke_subnets_02
  provider                                       = azurerm.connectivity
  name                                           = (each.value.name_suffix != "AzureFirewallSubnet") && (each.value.name_suffix != "AzureBastionSubnet") ? "${local.subnetprefix}-${each.value.name_suffix}" : each.value.name_suffix
  address_prefixes                               = each.value.address_prefixes
  resource_group_name                            = azurerm_resource_group.Virtual_Network.name
  virtual_network_name                           = azurerm_virtual_network.NonProd_Virtual_Network_01.name
  service_endpoints                              = each.value.service_endpoints
  enforce_private_link_endpoint_network_policies = true
  #enforce_private_link_service_network_policies = true
  depends_on = [
    azurerm_resource_group.Virtual_Network
  ]
}

#-----------------------------------------------------------------
# Spoke Virtual Network 03
#-----------------------------------------------------------------

resource "azurerm_virtual_network" "SS_Virtual_Network_01" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vnt-${var.spoke_ss_virtual_network_01.vnet_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  address_space       = var.spoke_ss_virtual_network_01.address_space
  tags                = var.tags
  dns_servers         = var.spoke_ss_virtual_network_01.dns_servers
}

#-----------------------------------------------------------------
# Spoke Subnets 03
#-----------------------------------------------------------------

resource "azurerm_subnet" "SS_Virtual_Network_Subnets_01" {
  for_each                                       = var.spoke_subnets_03
  provider                                       = azurerm.connectivity
  name                                           = (each.value.name_suffix != "AzureFirewallSubnet") && (each.value.name_suffix != "AzureBastionSubnet") ? "${local.subnetprefix}-${each.value.name_suffix}" : each.value.name_suffix
  address_prefixes                               = each.value.address_prefixes
  resource_group_name                            = azurerm_resource_group.Virtual_Network.name
  virtual_network_name                           = azurerm_virtual_network.SS_Virtual_Network_01.name
  service_endpoints                              = each.value.service_endpoints
  enforce_private_link_endpoint_network_policies = true
  #enforce_private_link_service_network_policies = true
  depends_on = [
    azurerm_resource_group.Virtual_Network
  ]
}

#-----------------------------------------------------------------
# IP Group to represent vNet address spaces, to use with the Azure Firewall Policies
#-----------------------------------------------------------------
resource "azurerm_ip_group" "virtual_wan_hubs" {
  for_each            = var.virtual_wan
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vwan-ipg-${each.value.name_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name

  cidrs = [each.value.address_prefix]
}

resource "azurerm_ip_group" "spoke_prod_virtual_network_01_subnets" {
  for_each            = var.spoke_subnets_01
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-sub-ipg-${each.value.name_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name

  cidrs = [each.value.address_prefixes[0]]
}

resource "azurerm_ip_group" "spoke_prod_virtual_network_01" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vnet-ipg-${var.spoke_prod_virtual_network_01.vnet_suffix}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name

  cidrs = var.spoke_prod_virtual_network_01.address_space
}

#-----------------------------------------------------------------
# Azure Virtual WAN
#-----------------------------------------------------------------
resource "azurerm_virtual_wan" "vwan" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vwan-${var.azurerm_virtual_wan_name_suffix}"
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  location            = var.region
}

#-----------------------------------------------------------------
# Azure Virtual WAN Hub/s
#-----------------------------------------------------------------
resource "azurerm_virtual_hub" "vwan_hubs" {
  for_each            = var.virtual_wan
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${each.value.region_code}-vwanhub-${each.value.environment}-${each.value.name_suffix}"
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  location            = each.value.region
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = each.value.address_prefix
}

#-----------------------------------------------------------------
# Azure Virtual WAN connections
#-----------------------------------------------------------------

# From Production vNet 01 - to Prod Hub
resource "azurerm_virtual_hub_connection" "prod_spoke_Virtual_Network_01" {
  provider                  = azurerm.connectivity
  name                      = "${var.environment_code}-${var.region_code}-vwanconn-${var.spoke_prod_virtual_network_01.vnet_suffix}"
  virtual_hub_id            = azurerm_virtual_hub.vwan_hubs["prod"].id
  remote_virtual_network_id = azurerm_virtual_network.Prod_Virtual_Network_01.id

  routing {
    associated_route_table_id   = azurerm_virtual_hub_route_table.prod_vWAN_Route_Table.id # (Optional) The ID of the route table associated with this Virtual Hub connection.
    propagated_route_table {
      labels                    = ["Shared", "Default"] # (Optional) The list of labels to assign to this route table.
      route_table_ids           = [azurerm_virtual_hub_route_table.prod_vWAN_Route_Table.id] # (Optional) A list of Route Table ID's to associated with this Virtual Hub Connection.
    }
    /*
    static_vnet_route {
      name                      = "" # (Optional) The name which should be used for this Static Route
      address_prefixes          = [] # (Optional) A list of CIDR Ranges which should be used as Address
      next_hop_ip_address       = [] # (Optional) The IP Address which should be used for the Next Hop
    }
    */
  }
  depends_on = [
    azurerm_virtual_hub_route_table.prod_vWAN_Route_Table
  ]
}

# From Non-Production vNet 01 - to Non-Prod Hub
resource "azurerm_virtual_hub_connection" "nonprod_spoke_Virtual_Network_01" {
  provider                  = azurerm.connectivity
  name                      = "${var.environment_code}-${var.region_code}-vwanconn-${var.spoke_nonprod_virtual_network_01.vnet_suffix}"
  virtual_hub_id            = azurerm_virtual_hub.vwan_hubs["non_prod"].id
  remote_virtual_network_id = azurerm_virtual_network.NonProd_Virtual_Network_01.id

  routing {
    associated_route_table_id   = azurerm_virtual_hub_route_table.nonprod_vWAN_Route_Table.id # (Optional) The ID of the route table associated with this Virtual Hub connection.
    propagated_route_table {
      labels                    = ["Shared", "Default"] # (Optional) The list of labels to assign to this route table.
      route_table_ids           = [azurerm_virtual_hub_route_table.nonprod_vWAN_Route_Table.id] # (Optional) A list of Route Table ID's to associated with this Virtual Hub Connection.
    }
    /*
    static_vnet_route {
      name                      = "" # (Optional) The name which should be used for this Static Route
      address_prefixes          = [] # (Optional) A list of CIDR Ranges which should be used as Address
      next_hop_ip_address       = [] # (Optional) The IP Address which should be used for the Next Hop
    }
    */
  }
  depends_on = [
    azurerm_virtual_hub_route_table.nonprod_vWAN_Route_Table
  ]
}

# From Shared Services vNet 01 - to Shared Services Hub
resource "azurerm_virtual_hub_connection" "ss_spoke_Virtual_Network_01" {
  provider                  = azurerm.connectivity
  name                      = "${var.environment_code}-${var.region_code}-vwanconn-${var.spoke_ss_virtual_network_01.vnet_suffix}"
  virtual_hub_id            = azurerm_virtual_hub.vwan_hubs["ss"].id
  remote_virtual_network_id = azurerm_virtual_network.SS_Virtual_Network_01.id
  
  routing {
    associated_route_table_id   = azurerm_virtual_hub_route_table.ss_vWAN_Route_Table.id # (Optional) The ID of the route table associated with this Virtual Hub connection.
    propagated_route_table {
      labels                    = ["Default", "Prod", "Non-Prod"] # (Optional) The list of labels to assign to this route table.
      route_table_ids           = [azurerm_virtual_hub_route_table.ss_vWAN_Route_Table.id] # (Optional) A list of Route Table ID's to associated with this Virtual Hub Connection.
    }
    /*
    static_vnet_route {
      name                      = "" # (Optional) The name which should be used for this Static Route
      address_prefixes          = [] # (Optional) A list of CIDR Ranges which should be used as Address
      next_hop_ip_address       = [] # (Optional) The IP Address which should be used for the Next Hop
    }
    */
  }
  depends_on = [
    azurerm_virtual_hub_route_table.ss_vWAN_Route_Table
  ]
}

#-----------------------------------------------------------------
# Azure Virtual WAN Route Table
#-----------------------------------------------------------------
# Prod Hub
resource "azurerm_virtual_hub_route_table" "prod_vWAN_Route_Table" {
  provider       = azurerm.connectivity
  name           = "${var.environment_code}-${var.region_code}-vwanrt-${var.virtual_wan["prod"].environment}"
  virtual_hub_id = azurerm_virtual_hub.vwan_hubs["prod"].id
  labels         = ["Prod"]
/*
  route {
    name              = "Shared_Services_01"
    destinations_type = "CIDR" # (Required) The type of destinations. Possible values are CIDR, ResourceId and Service
    destinations      = var.spoke_ss_virtual_network_01.address_space # (Required) A list of destination addresses for this route.
    next_hop_type     = "ResourceId" # (Optional) The type of next hop. Currently the only possible value is ResourceId. Defaults to ResourceId
    next_hop          = azurerm_virtual_hub_connection.ss_spoke_Virtual_Network_01.id # (Required) The next hop's resource ID
  }
  */
}

# Non-Prod Hub
resource "azurerm_virtual_hub_route_table" "nonprod_vWAN_Route_Table" {
  provider       = azurerm.connectivity
  name           = "${var.environment_code}-${var.region_code}-vwanrt-${var.virtual_wan["non_prod"].environment}"
  virtual_hub_id = azurerm_virtual_hub.vwan_hubs["non_prod"].id
  labels         = ["Non-Prod"]
/*
  route {
    name              = "Shared_Services_01"
    destinations_type = "CIDR"
    destinations      = var.spoke_ss_virtual_network_01.address_space
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_virtual_hub_connection.ss_spoke_Virtual_Network_01.id
  }
  */
}

# Shared Services Hub
resource "azurerm_virtual_hub_route_table" "ss_vWAN_Route_Table" {
  provider       = azurerm.connectivity
  name           = "${var.environment_code}-${var.region_code}-vwanrt-${var.virtual_wan["ss"].environment}"
  virtual_hub_id = azurerm_virtual_hub.vwan_hubs["ss"].id
  labels         = ["Shared"]
/*
  route {
    name              = "SS_01"
    destinations_type = "CIDR"
    destinations      = var.spoke_ss_virtual_network_01.address_space
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_virtual_hub_connection.ss_spoke_Virtual_Network_01.id
  }
  */
}

#-----------------------------------------------------------------
# Azure Virtual WAN VPN Gateway
#-----------------------------------------------------------------

# Production ER Gateway
resource "azurerm_express_route_gateway" "prod_vWAN_ER_Gateway" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vwanergw-${var.virtual_wan["prod"].environment}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  virtual_hub_id      = azurerm_virtual_hub.vwan_hubs["prod"].id
  scale_units         = 1 # (Required) The number of scale units with which to provision the ExpressRoute gateway. Each scale unit is equal to 2Gbps, with support for up to 10 scale units (20Gbps)
  depends_on = [
    azurerm_virtual_hub.vwan_hubs
  ]
}

# Non Production ER Gateway
resource "azurerm_express_route_gateway" "nonprod_vWAN_ER_Gateway" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vwanergw-${var.virtual_wan["non_prod"].environment}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  virtual_hub_id      = azurerm_virtual_hub.vwan_hubs["non_prod"].id
  scale_units         = 1 # (Required) The number of scale units with which to provision the ExpressRoute gateway. Each scale unit is equal to 2Gbps, with support for up to 10 scale units (20Gbps)
  depends_on = [
    azurerm_virtual_hub.vwan_hubs
  ]
}

# Shared Services ER Gateway
resource "azurerm_express_route_gateway" "ss_vWAN_ER_Gateway" {
  provider            = azurerm.connectivity
  name                = "${var.environment_code}-${var.region_code}-vwanergw-${var.virtual_wan["ss"].environment}"
  location            = var.region
  resource_group_name = azurerm_resource_group.Virtual_Network.name
  virtual_hub_id      = azurerm_virtual_hub.vwan_hubs["ss"].id
  scale_units         = 1 # (Required) The number of scale units with which to provision the ExpressRoute gateway. Each scale unit is equal to 2Gbps, with support for up to 10 scale units (20Gbps)
  depends_on = [
    azurerm_virtual_hub.vwan_hubs
  ]
}
