# Components of a Managed Application

| **Component**                  | **Description**                                                                                 |
|-------------------------------|-------------------------------------------------------------------------------------------------|
| **Managed Application**        | A solution deployed in a customer’s subscription, with resources managed by the publisher.      |
| **Application Definition**     | A template (ARM/Bicep) that defines the solution’s infrastructure and metadata.                 |
| **Application Package**        | A `.zip` file that includes the main ARM template, `createUiDefinition.json`, and optionally scripts. |
| **CreateUiDefinition.json**    | Defines the UI experience in the Azure portal during deployment.                                |
| **Managed Resource Group (MRG)** | The resource group where your app’s resources are deployed. The customer can see it but can’t modify it. |
| **Billing Model**              | You can monetize through the Azure Marketplace (plans, pricing, metering).                     |
| **Roles and Access**           | Customers get RBAC access to the app itself, but you (publisher) get Contributor/Owner to the MRG. |

---

# Which Resource Group Does the Customer Manage?

When you deploy a Managed Application, there are always **two resource groups** involved:

| **Resource Group**                         | **Who Owns It** | **Purpose**                                                                 |
|-------------------------------------------|------------------|------------------------------------------------------------------------------|
| **Customer RG** (where the Managed Application object lives) | **Customer**     | Holds the Managed Application resource object (not the real infra). Customer can see the app, view parameters, and delete the application. |
| **Managed Resource Group (MRG)**           | **Publisher (You)** | Contains all the deployed infrastructure (VMs, Storage, App Services, etc.). Customer cannot edit or delete the resources unless you explicitly allow it via RBAC. |

---

✅ **In summary:**

- The customer **doesn’t manage** the deployed infrastructure directly.
- The customer **can see** the MRG, but **can't modify** it unless you grant roles inside it.
- You (the publisher) get **Contributor or higher** access to the MRG, depending on how you configure the `authorizations`.
