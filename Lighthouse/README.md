Azure Lighthouse

When a customer’s subscription or resource group is onboarded to Azure Lighthouse, two resources are created:

- Registration definition.
- Registration assignment.

Registration Definition
The registration definition contains the details of the Azure Lighthouse offer (the managing tenant ID and the authorizations) that assign built-in roles to specific users, groups, and/or service principals in the managing tenant.

A registration definition is created at the subscription level for each delegated subscription, or in each subscription that contains a delegated resource group.

Registration assignment
The registration assignment assigns the registration definition to a specific scope—that is, the onboarded subscription(s) and/or resource group(s).

A registration assignment is created in each delegated scope, so it will either be at the subscription group level or the resource group level, depending on what was onboarded.

Each registration assignment must reference a valid registration definition at the subscription level, tying the authorizations for that service provider to the delegated scope and thus granting access.

## Define roles and permissions

As a service provider, you may want to perform multiple tasks for a single customer, requiring different access for different scopes. You can define as many authorizations as you need in order to assign the appropriate Azure built-in roles.

## Create an Azure Resource Manager Template

You can create this template from the Azure Portal and it's a really easy way, hoewver, you can also create it manually if you prefer so.

To onboard your customer, you'll need to create an Azure Resource Manager template with the registration definition and the registration assignment.

The delegation is defined through the following resource:

### Registration Definition:

```
{
  "type": "Microsoft.ManagedServices/registrationDefinitions",
  "apiVersion": "2019-09-01",
  "name": "[guid(subscription().id, 'lighthouse-delegation')]",
  "properties": {
    "registrationDefinitionName": "Brandon Delegation",
    "description": "Delegation to Brandon's tenant for managing resources",
    "managedByTenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "authorizations": [
      {
        "principalId": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
        "principalIdDisplayName": "Brandon Admin",
        "roleDefinitionId": "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c" // Contributor
      }
    ]
  }
}
```

#### Azure Lighthouse Delegation Template – Properties Table

| Property                     | Required? | Description                                                                                     |
| ---------------------------- | --------- | ----------------------------------------------------------------------------------------------- |
| `registrationDefinitionName` | ✅ Yes    | Friendly name to identify the delegation registration.                                          |
| `description`                | ✅ Yes    | Description of the delegation's purpose.                                                        |
| `managedByTenantId`          | ✅ Yes    | Tenant ID of the managing tenant (the one that will get access to the customer’s resources).    |
| `authorizationType`          | ✅ Yes    | Must be set to `"DelegatedProvider"` to indicate it's for Azure Lighthouse.                     |
| `authorizations`             | ✅ Yes    | Array of identities (users/groups/service principals) from the managing tenant and their roles. |
| `eligibleAuthorizations`     | ❌ No     | Used with Azure AD PIM for just-in-time access (usually left empty).                            |
| `plan`                       | ❌ No     | Required only when publishing a Managed Services offer on Azure Marketplace.                    |

#### Nested inside `authorizations` array:

| Property                 | Required? | Description                                                                               |
| ------------------------ | --------- | ----------------------------------------------------------------------------------------- |
| `principalId`            | ✅ Yes    | Object ID of the identity (user/group/SPN) from the managing tenant being granted access. |
| `roleDefinitionId`       | ✅ Yes    | Azure Role Definition ID (e.g., Reader, Contributor, or custom role).                     |
| `principalIdDisplayName` | ❌ No     | Optional name shown for clarity (does not affect functionality).                          |

#### Nested inside `plan` object (if used):

| Property    | Required? | Description                                                |
| ----------- | --------- | ---------------------------------------------------------- |
| `name`      | ✅ Yes    | Name of the service plan (e.g., `Standard`, `Enterprise`). |
| `publisher` | ✅ Yes    | Name of the service provider (e.g., your company name).    |
| `product`   | ✅ Yes    | Name of the product being offered (shown on Marketplace).  |
| `version`   | ✅ Yes    | Version of the service plan.                               |

### Registration Assignment resource:

```
{
  "type": "Microsoft.Resources/deployments",
  "apiVersion": "2018-05-01",
  "name": "rgAssignment",
  "resourceGroup": "[parameters('rgName')]",
  "dependsOn": [
    "[resourceId('Microsoft.ManagedServices/registrationDefinitions/', variables('mspRegistrationName'))]"
  ],
  "properties": {
    "mode": "Incremental",
    "template": {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {},
      "resources": [
        {
          "type": "Microsoft.ManagedServices/registrationAssignments",
          "apiVersion": "2020-02-01-preview",
          "name": "[variables('mspAssignmentName')]",
          "properties": {
            "registrationDefinitionId": "[resourceId('Microsoft.ManagedServices/registrationDefinitions/', variables('mspRegistrationName'))]"
          }
        }
      ]
    }
  }
}
```

You can review the complete template on the delegationTemplate.json file of this repository.

We can see examples of the delegation whether for subscription or resource groups in the Azure Lighthouse repository: https://github.com/Azure/Azure-Lighthouse-samples/tree/master/templates/delegated-resource-management
