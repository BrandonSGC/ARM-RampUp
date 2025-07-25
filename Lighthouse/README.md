# Azure Lighthouse Overview

Azure Lighthouse enables service providers to manage customer resources at scale, with high automation, security, and control. When a customer’s subscription or resource group is onboarded to Azure Lighthouse, two key Azure resources are created:

- **Registration Definition**
- **Registration Assignment**

---

## 📘 Registration Definition

The **registration definition** contains the details of the Azure Lighthouse offer, including:

- The **managing tenant ID**
- The **authorizations**, which assign built-in roles to specific users, groups, or service principals in the managing tenant

A registration definition is always created at the **subscription level**:

- One per **delegated subscription**, or
- One in each **subscription that contains a delegated resource group**

---

## 📘 Registration Assignment

The **registration assignment** ties the registration definition to a specific scope—either:

- One or more **subscriptions**, or
- Specific **resource groups**

Each registration assignment:

- Is created in the **delegated scope** (subscription or resource group)
- References a valid registration definition from the subscription level
- Grants the authorized managing tenant access to that scope

---

## 🔐 Define Roles and Permissions

As a service provider, you may need different levels of access for different scenarios. Azure Lighthouse allows you to define **multiple authorizations** in your registration definition to grant appropriate **Azure built-in roles** (or custom roles) to each identity.

---

## 🛠️ Creating an Azure Resource Manager Template

You can create a delegation template via:

- The **Azure Portal** (easiest)
- A **manually authored** ARM or Bicep template (more customizable)

To onboard your customer, define both the **registration definition** and **registration assignment** in your template.

---

## 🧩 Sample Registration Definition

```json
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
        "roleDefinitionId": "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
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

```json
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
