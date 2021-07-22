# Terraform-Azure-Virtual-WAN-no-Azure-Firewall


<img src="blobs/AzureLogo2021.png" width="100" align="right"/>

# Overview
Multi-environment (Prod / Non-Prod / Shared Services) using Azure Virtual WAN, with 3 vWAN hubs in the same region to provide total isolation of the network. This focuses on the Azure side of things, as a second step to this, you would connect to this from on-prem using either ExpressRoute or VPN.

<img src="blobs/Screenshot%202021-07-21%20191501.png" width="2000"/>

## Deployment Instructions
> [!NOTE]
> In the real world for large enterprise companies, you would most likely already have access to **Terraform Cloud** and also have a CI/CD setup. So I assume you already know how Terraform works with respect to deployment. In this instance, you take these Terraform files from this repo and build on top of these, do what you will.

Else, as a quick start, you can run this as a test, in a non-prod/dev environment to have a play and see how/what deploys into Azure. 

Below the instructions to quickly run the Terraform in this repository with the least amount of effort. Easiest way to do this is using **CloudDrive** from within **Azure Cloud Shell**. The CloudDrive is literally just an Azure Files share in your Azure subscription which saves state and in which you can host files. In this instance, you can host Terraform files form this repo.

> [!NOTE]
> [Cloud Shell automatically has the latest version of Terraform installed](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell). Also, Terraform automatically uses information from the current Azure subscription. As a result, there's no installation or configuration required. 

### VS Code
Download and Install [Visual Studio Code](https://code.visualstudio.com/download)

Install the **Azure Account** extension

![](blobs/Screenshot%202021-07-22%20095015.png)

In VS Code, hit **F1** or **CTRL+SHIFT+P**, then **Sign in to Azure**. 

![](blobs/Screenshot%202021-07-22%20104240.png)

In VS Code, hit **F1** again, then **open Bash in Cloud Shell**. 

![](blobs/Screenshot%202021-07-22%20094811.png)

### List clouddrive
Assuming you have previously connected to Cloud Shell before and already setup the Storage Account [more details here](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage) Next, you will need to connect to the Azure Files share in which CloudDrive is configured to use, so you can copy and paste the Terraform files in this repo. [To see which Azure Files share CloudDrive is using](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage#list-clouddrive), run the `df` command.

```
justin@Azure:~$ df
Filesystem                                          1K-blocks   Used  Available Use% Mounted on
overlay                                             29711408 5577940   24117084  19% /
tmpfs                                                 986716       0     986716   0% /dev
tmpfs                                                 986716       0     986716   0% /sys/fs/cgroup
/dev/sda1                                           29711408 5577940   24117084  19% /etc/hosts
shm                                                    65536       0      65536   0% /dev/shm
//mystoragename.file.core.windows.net/fileshareName 5368709120    64 5368709056   1% /home/justin/clouddrive
justin@Azure:~$
```
In this instance, the storage account is **mystoragename** and the Azure Files Share is **fileshareName**.
### Mount SMB Azure file share
Next thing you need to do is mount the Azure Files Share on your local device, Windows, Linux, macOS - [https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows)

Once the Azure Files share is mounted, simply create a folder in the root of the drive and copy the files in this repo to it.

### Variables to change
In the **variables.tf** file, there's a list of variables to change to suit your own environment. Make sure you run through this and make the necessary changes. It should be fairly obvious which variables you need to change. For starters, one that you definitely would want to change is the Azure Subscription ID

```
variable "connectivity_subscription_id" {
  type    = string
  default = "6bx002x5-54x6-4xb1-9xca-5bxefx18x0bx"
}
```

We are using provider alias's throughout, this gives us the flexibility to deploy across multiple subscriptions on a resource by resouce basis. This means that on a per resource basis you'll see this line included `provider            = azurerm.connectivity` for every resource, here we're specifying which Azure subscription to use.

If you want to deploy any resources to other subscriptions, e.g. the spoke Virtual Networks, you can. 

Simply create another provider in the **terraform.tf** file, similar to:

![](blobs/Screenshot%202021-07-22%20111622.png)

Also create another variable in the **variables.tf** file similar to:

![](blobs/Screenshot%202021-07-22%20111659.png)
### Terraform Commands in Cloud Shell
In Cloud Shell, run `cd CloudDrive` - at this point, you're at the same location as what you see in the Azure Files Share that has been mounted.

Run `ls` to view the contents of the folder. 

Run `cd FolderName` to change to the folder name containing the Terraform Files to which you created just before

Run `Terraform Init` to first initialise the folder to be used with Terraform

Option: Run `Terraform Validate` to validate the code. (if you just copied files directly fro this repo, then no errors should appear)

Run `Terraform plan` to see what will be deployed

Run `Terraform apply -auto-approve` to apply the configuration directly to Azure.

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
### Connections
- Anything that is connected to a VirtualHub​
  - Vnets - HubVnetConnection​
  - VPN GW - VPNConnection​
  - ER GW - ERConnection​
  - P2S GW – P2S config Connection​
- Can have static routes, directing traffic for a tiered spoke through an NVA​

### Propagation
Connections dynamically propagate routes to a route table. Routes can be propagated to one or multiple route tables. Propagating to the **none** route table implies that no routes are required to be propagates from that connection.

You can propagate routes to a route table directly, or you can propagate routes to route table **labels**. Labels provide a mechanism to logically group route tables and exist across all hubs. For example, the Default Route Table has a built-in label called **Default**. When users propagate connection routes to the **Default** label, it automatically applies to all the **Default** labelled Route Tables across every hub in the Virtual WAN. When creating a route table, you can add one or many labels to this route table. 
- Connections dynamically propagate routes to a route table
- Routes can be propagated to one or multiple route tables
- Route Tables across Hubs can be groups under labels, you can propagate routes to one or multiple route table labels
### Association​
Association allows the connection to reach all the routes in the route table. Multiple connections can be associated to the same route table. VPN Sites, User VPN and ExpressRoute connections are required to be associated to the **default** route table. Each virtual hub has its own default route table, to which you can add static routes. A **static route** takes precedence over dynamically learned routes. 
- Each connection is associated to one route table
- Custom RT used for vNets
- Branches must be associated with the Default RT


[![Alt text](https://img.youtube.com/vi/reuK7XIHuog/0.jpg)](https://www.youtube.com/watch?v=reuK7XIHuog)

## Route Tables
- Collection of routes in each Hub
- Each Hub may contain multiple Route Tables​
- Each Hub always contains Default and None​
- Route Tables across Hubs can be grouped under Labels​
- Routes: Destination prefix -> Next Hop, example 10.0.1.0/24 ->  VNET_A_1_conn​

### Routes​
- Destination: CIDR prefix e.g. 10.0.1.0/24​
- Next Hop: Connection, AzFW, Remote Hub​
### Labels​
- Collections of Route Tables across Hubs​

[![Alt text](https://img.youtube.com/vi/MExWr_kEa_0/0.jpg)](https://www.youtube.com/watch?v=MExWr_kEa_0)

## Custom Route Tables

[![Alt text](https://img.youtube.com/vi/nEt79WbRCoY/0.jpg)](https://www.youtube.com/watch?v=nEt79WbRCoY)

## Putting it all together

[![Alt text](https://img.youtube.com/vi/vRW9piJwzHM/0.jpg)](https://www.youtube.com/watch?v=vRW9piJwzHM)