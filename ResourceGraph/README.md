# What is Azure Resource Graph

ARG extends from ARM and provides efficient and performant resource exploration. Resource Graph hast the ability to query at scale across a given set of subscriptions so that you can effectively govern your environment. These queries provide the following abilities:

- Query resources with complex filtering, grouping, and sorting by resource properties.
- Explore resources iteratively based on governance requirements.
- Assess the effect of applying policies in a vast cloud environment.
- Query changes made to resource properties.

## How Resource Graph is kept current

When an Azure resource is updated, Azure Resource Manager notifies Azure Resource Graph about the change. Azure Resource Graph then updates its database. Azure Resource Graph also does a regular full scan. This scan ensures that Azure Resource Graph data is current if there are missed notifications. Or when a resource is updated outside of Azure Resource Manager.


## Permissions in Azure Resource Graph
To use Resource Graph, you must have appropriate rights in Azure role-based access control (Azure RBAC) with at least read access to the resources you want to query. No results are returned if you don't have at least read permissions to the Azure object or object group.


## Run Queries on Azure CLI:

First we need to add the resource graph extension, for this we can run the following commands:

- az extension list-available --output table
- az extension add --name resource-graph
- az extension list --output table
- az graph query --help

Once the installation of the extension is completed we can run queries. Example

```bash
az graph query --graph-query 'Resources | project name, type | limit 5 | order by name asc'
```

from that command, in my case I got the following result:

```json
{
  "count": 5,
  "data": [
    {
      "name": "bgc-vm",
      "type": "microsoft.compute/virtualmachines"
    },
    {
      "name": "bgc-vm-nsg",
      "type": "microsoft.network/networksecuritygroups"
    },
    {
      "name": "bgc-vm-vnet-default-nsg-centralus",
      "type": "microsoft.network/networksecuritygroups"
    },
    {
      "name": "bgc-vm996_z1",
      "type": "microsoft.network/networkinterfaces"
    },
    {
      "name": "bgc-vm_OsDisk_1_42eb9f08affa47c6addf2a0464435fdc",
      "type": "microsoft.compute/disks"
    }
  ],
  "skip_token": null,
  "total_records": 5
}
```

## Run Queries on PowerShell:

```powershell
Search-AzGraph -Query 'Resources | project name, type | limit 5 | order by name asc'
```

## Run Queries using REST API:

send HTTP request via CLI:

```bash
az rest --method post --uri https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01 --body `@request-body.json
```

## Types of Queries

Azure Resource Graph Explorer lets you save your Resource Graph queries directly in the Azure portal. There are two types of queries: Private and Shared. A Private query is saved in your Azure portal settings. Whereas a Shared query is an Azure Resource Manager resource that can be managed with Azure role-based access control (Azure RBAC) and protected with resource locks.

### Private Query

Private queries are accessible and visible only to the account that creates them. As they're saved in an account's Azure portal settings, they can be created, used, and deleted only from inside the Azure portal. A Private query isn't a Resource Manager resource.

### Shared Query

Unlike a Private query, a Shared query is a Resource Manager resource. This fact means the query gets saved to a resource group, can be managed and controlled with Azure RBAC, and can even be protected with resource locks. As a resource, anyone who has the appropriate permissions can see and use it.

#### Create a shared query

Azure CLI

Powershell

#### Deploy a shared query

ARM

Bicep

Lab: Check the PolicyResources of the delegated subscription you included in the previous Lighthouse section and show only a set of properties that you choose.
