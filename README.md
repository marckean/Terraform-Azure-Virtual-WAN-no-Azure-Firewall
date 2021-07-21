# Terraform-Azure-Virtual-WAN-no-Azure-Firewall




<img src="blobs/AzureLogo2021.png" width="100" align="right"/>

# Overview
In this section we have a look at "the what", **what** is deployed using this code in its current state. This is using BHP's asset **Petroleum** as the example asset. 
<img src="blobs/Screenshot%202021-07-21%20191501.png" width="2000"/>
## Deployment Instructions
This is where you find all the instructions to run this repository in amongst the the other repositories. To begin with, repositories must be run in order and each subsequent repository is dependent on the lower level repository. Once all repositories have been run successfully once and in full, then the repositories can be run again in any order for any changes that are required.

Before you deploy:

- Read "the how", the deployment manual found [here](https://bhptechsi.atlassian.net/wiki/spaces/CLOUD/pages/2212462775/OT+Landing+Zone+-+IaC+handbook+the+how)
- Follow the [prerequisites](https://bhptechsi.atlassian.net/wiki/spaces/CLOUD/pages/2212462775/OT+Landing+Zone+-+IaC+handbook+the+how#Prerequisites)
- Change the [Azure Region](https://bhptechsi.atlassian.net/wiki/spaces/CLOUD/pages/2212462775/OT+Landing+Zone+-+IaC+handbook+the+how#Region) if needed
- Change the details (including asset name) of the top-level [Management Group](https://bhptechsi.atlassian.net/wiki/spaces/CLOUD/pages/2212462775/OT+Landing+Zone+-+IaC+handbook+the+how#Management-Group-Details)

## Deployed Items
The below is "the what", **what** is deployed with this repository.  
### Azure Virtual WAN (vWAN)
<img src="blobs/Azure/10353-icon-Virtual WANs-Networking.svg" width="70"/>

Azure vWAN itself, only one deployed into a subscription named **Connectivity**.

### vWAN hubs
<img src="blobs/Azure/00753-icon-Virtual Hubs-menu.svg" width="70"/>

A total of 3 virtual hubs are deployed in the same region inside of the one Azure vWAN. Each hub is earmarked to be used for each environment, Prod / Shared Services / Non-Prod.
<img src="blobs/vWAN%20hubs.png" width="300"/>

### Virtual Network Connections
<img src="blobs/Azure/00750-icon-Virtual Network Connections-menu.svg" width="70"/>

This is fairly stock standard, spoke vNets in each environment Prod / Shared Services / Non-Prod connected to the relevant vWAN hub. 



### Virtual Hub Routing
<img src="blobs/Azure/00654-icon-Routing-menu.svg" width="70"/>

As for the **custom** route tables in the vWAN hubs, this is what the effective routes look like:

| Route Table Name | Prefix | Next Hop Type | Next Hop |
|--------|--------|--------|--------|
con-aue-vwanrt-prod | 10.1.0.0/21 | Virtual Network Connection | con-aue-vnt-prod_spoke_01
con-aue-vwanrt-prod | 10.1.16.0/21 | Remote Hub | con-aue-vwanhub-ss-003
con-aue-vwanrt-ss | 10.1.16.0/21 | Virtual Network Connection | con-aue-vwanconn-ss_spoke_01
con-aue-vwanrt-ss | 10.1.0.0/21 | Remote Hub | con-aue-vwanhub-prod-001
con-aue-vwanrt-ss | 10.1.8.0/21 | Remote Hub | con-aue-vwanhub-non_prod-002
con-aue-vwanrt-non_prod | 10.1.8.0/21 | Virtual Network Connection | con-aue-vwanconn-nonprod_spoke_01
con-aue-vwanrt-non_prod | 10.1.16.0/21 | Remote Hub | con-aue-vwanhub-ss-003



### Virtual Networks
<img src="blobs/Azure/Icon-networking-61-Virtual-Networks.svg" width="70"/>


The following Virtual Networks are deployed to BHP's Petroleum OT Production environment:

| Name | Address Space | Subnet | Subnet Address Range |
|--------|--------|--------|--------|
con-aue-vnt-nonprod_spoke_01 | 10.1.8.0/21 | con-aue-001<br>con-aue-002 | 10.1.8.0/24<br>10.1.9.0/24 |
con-aue-vnt-prod_spoke_01 | 10.1.0.0/21 | con-aue-001<br>con-aue-002 | 10.1.0.0/24<br>10.1.1.0/24 |
con-aue-vnt-ss_spoke_01 | 10.1.16.0/21 | con-aue-001<br>con-aue-002 | 10.1.16.0/24<br>10.1.17.0/24 |

# Understanding vWAN routing

Routing in vWAN can get a little complicated... But I've taken snippets from this [video](https://www.microsoft.com/azure/partners/videos/azure-networking-services) (as shown below) to help explain vWAN routing in more detail. 

This covers:

- Connection & Propagation
- Route Tables
- Custom Route Tables
- Putting it all together


## Connection & Propagation
[![Alt text](https://img.youtube.com/vi/reuK7XIHuog/0.jpg)](https://www.youtube.com/watch?v=reuK7XIHuog)

## Route Tables

[![Alt text](https://img.youtube.com/vi/MExWr_kEa_0/0.jpg)](https://www.youtube.com/watch?v=MExWr_kEa_0)

## Custom Route Tables

[![Alt text](https://img.youtube.com/vi/nEt79WbRCoY/0.jpg)](https://www.youtube.com/watch?v=nEt79WbRCoY)

## Putting it all together

[![Alt text](https://img.youtube.com/vi/vRW9piJwzHM/0.jpg)](https://www.youtube.com/watch?v=vRW9piJwzHM)