# Policy Notes

## Structure of a Policy Definition

| **Component** | **Required** | **Description**                                          |
| ------------- | ------------ | -------------------------------------------------------- |
| `name`        | ✅ Yes       | Name of the policy definition.                           |
| `type`        | ✅ Yes       | Always `Microsoft.Authorization/policyDefinitions`.      |
| `displayName` | ✅ Yes       | Friendly name shown in the Azure Portal.                 |
| `description` | ✅ Yes       | Describes what the policy does.                          |
| `mode`        | ✅ Yes       | Either `All`, `Indexed`, or `Microsoft.Kubernetes.Data`. |
| `parameters`  | No           | Defines user-provided inputs to customize behavior.      |
| `policyRule`  | ✅ Yes       | The core logic — `if` conditions and `then` effect.      |
| `metadata`    | No           | Optional metadata such as version or category.           |

### Important things to know about mode property:

The mode is configured depending on if the policy is targeting an Azure Resource Manager property or a Resource Provider property

#### Resource Manager Modes

- **All**: Evaluate resource groups, subscriptions, and all resources.
- **Indexed**: only evaluate resource types that support tags and locations.

## Policy Effects

Each policy definition in Azure Policy has a single _effect_ in its _policyRule_. That effect determines what happens when the policy rule is evaluated to match. The effects behave differently if they are for a new resource, an updated resource, or an existing resource.

| Effect              | Description                                                                 |
| ------------------- | --------------------------------------------------------------------------- |
| `deny`              | Blocks deployment if non-compliant                                          |
| `audit`             | Logs non-compliant resources                                                |
| `auditIfNotExists`  | Audits only if related resource doesn't exist                               |
| `deployIfNotExists` | Automatically deploys a related resource if it doesn’t exist                |
| `append`            | Adds fields to a resource during deployment                                 |
| `disabled`          | Policy exists but doesn't do anything                                       |
| `modify`            | Alters a request during creation by changing values before deployment       |
| `addToNetworkGroup` | Adds a resource to a specified network group (used with Microsoft Defender) |
| `denyAction`        | Blocks specific actions (operations) on a resource                          |
| `manual`            | Indicates manual enforcement is required; no automatic effect is applied    |
| `mutate`            | Alters a resource after creation (e.g., updates config post-deployment)     |

### Important notes regarding certain effects:

#### AuditIfNotExists

This effect enables auditing of resources related to the resource that matches the if condition, but don't have the properties specified in the details of the then condition. For example:

- The custom policy we have created is going to audit if Virtual Machines have diagnostic settings configured
- This diagnostic settings is just a resource which is related to the Virtual Machine.

#### DeployIfNotExists

A template deployment occurs if there are no related resources or if the resources defined by existenceCondition don't evaluate to true.

## Aliases

You use property aliases to access specific properties for a resource type.

### Array aliases

Look inside an array of objects and apply the condition to each item. For example:

You want to check that all network interfaces attached to a VM are in a certain subnet.
That’s an array — because a VM can have multiple NICs.

You’d use this alias:
"field": "Microsoft.Network/networkInterfaces[*].subnet.id"

## Greenfield vs Brownfield

### Greenfield:

- Refers to new resources that will be created after the policy is assigned.
- The policy is evaluated during creation of the resource.
- This is the default behavior of Azure Policy — it applies the policy to all future deployments

### Brownfield:

- Refers to resources that already exist before the policy was assigned.
- Azure Policy evaluates compliance of these existing resources — but does not modify them automatically.
- To take action on existing resources, you need to create a remediation task.

## What is the difference between an Initiative and a Definition?

### Initiative

An initiative is a group of policies (definitions) bundled together for easier management and reporting.

### Assignment

An assignment is the act of applying a policy definition or initiative to a specific scope (like a subscription, resource group, or management group).

#### Structure of an Assignment

| **Property**                  | **Required**            | **Description**                                                                                    |
| ----------------------------- | ----------------------- | -------------------------------------------------------------------------------------------------- |
| `name`                        | ✅ Yes                  | The unique name of the policy assignment.                                                          |
| `scope`                       | ✅ Yes                  | The target scope (management group, subscription, or resource group) where the policy is assigned. |
| `policyDefinitionId`          | ✅ Yes                  | The full resource ID of the policy definition or initiative.                                       |
| `displayName`                 | No                      | Friendly name shown in Azure Portal.                                                               |
| `description`                 | No                      | A human-readable explanation of the assignment.                                                    |
| `enforcementMode`             | No                      | Use `DoNotEnforce` to bypass enforcement but still evaluate compliance. Default is `Default`.      |
| `parameters`                  | Depends                 | Required if the policy definition has parameters. Used to provide values to them.                  |
| `nonComplianceMessages`       | No                      | Optional messages shown when a resource is non-compliant.                                          |
| `notScopes`                   | No                      | Array of resource IDs to exclude from the policy assignment.                                       |
| `location`                    | ✅ Yes (if remediation) | Required for policies using `deployIfNotExists` or `modify`. Specifies deployment region.          |
| `identity`                    | ✅ Yes (if remediation) | Specifies a managed identity for remediation deployments.                                          |
| `metadata`                    | No                      | Internal metadata such as version, owner, or category.                                             |
| `policyDefinitionReferenceId` | No (initiatives only)   | ID of a policy within an initiative, useful when assigning parameters per-policy.                  |

#### Exemptions and exlusions in Assignments

**Exclusion**

- An exlusion is defined during a policy assignment, it basically excludes specific scopes from the assignment (like a resource group or resource).
- For an exclusion we need the "notScopes" properti. Example:

```
"notScopes": [
  "/subscriptions/16e28336-0da6-4238-bf6c-6f3ee682a721/resourceGroups/MyResources"
]
```

**Exemption**

- An exemption is created after a policy or initiative is assigned and is used to temporarily waive compliance on specific resources without disabling the assignment.
- You can set a justification, expiration date, and category (Mitigated = "Temporary exemption", Waiver = "Permanent exemption", etc...).
- Azure Policy Insights will still show that the resource is non-compliant, but with an exempted status.
- We can create the exemption using the Azure Portal, PowerShell, Azure CLI...

Exemption example:

```
{
  "id": "/subscriptions/{subId}/resourceGroups/{rgName}/providers/Microsoft.Authorization/policyExemptions/resourceIsNotApplicable",
  "apiVersion": "2020-07-01-preview",
  "name": "resourceIsNotApplicable",
  "type": "Microsoft.Authorization/policyExemptions",
  "properties": {
    "displayName": "This resource is scheduled for deletion",
    "description": "This resources is planned to be deleted by end of quarter and has been granted a waiver to the policy.",
    "metadata": {
      "requestedBy": "Storage team",
      "approvedBy": "IA",
      "approvedOn": "2020-07-26T08:02:32.0000000Z",
      "ticketRef": "4baf214c-8d54-4646-be3f-eb6ec7b9bc4f"
    },
    "policyAssignmentId": "/subscriptions/{mySubscriptionID}/providers/Microsoft.Authorization/policyAssignments/resourceShouldBeCompliantInit",
    "policyDefinitionReferenceId": [
      "requiredTags",
      "allowedLocations"
    ],
    "exemptionCategory": "waiver",
    "expiresOn": "2020-12-31T23:59:00.0000000Z",
    "assignmentScopeValidation": "Default"
  }
}
```

Here is a table with the structure of an Exemption
| **Property** | **Required** | **Description** |
|-------------------------|--------------|---------------------------------------------------------------------------------|
| `name` | ✅ Yes | The unique name for the exemption. |
| `scope` | ✅ Yes | The full scope (resource, resource group, subscription) the exemption applies to. |
| `policyAssignmentId` | ✅ Yes | The resource ID of the policy assignment being exempted. |
| `displayName` | No | Friendly name to show in the portal. |
| `description` | No | Explanation of why the exemption is being applied. |
| `exemptionCategory` | ✅ Yes | The reason type: `Waiver` (permanent) or `Mitigated` (temporary or in progress). |
| `expiresOn` | No | Optional expiration date/time in ISO 8601 format (`2025-12-31T23:59:59Z`). |
| `metadata` | No | Optional metadata like who approved it, tracking info, or notes. |
| `resourceSelectors` | No | Filters to apply the exemption only to certain resources at the same scope. |

## Remediation tasks

Azure Policy remediation task feature is used to bring resources into compliance established from a definition and assignment. Resources that are non-compliant to a modify or deployIfNotExists definition assignment, can be brought into compliance using a remediation task. A remediation task deploys the deployIfNotExists template or the modify operations to the selected non-compliant resources using the identity specified in the assignment.

### Structure

| **Property**            | **Required** | **Description**                                                                           |
| ----------------------- | ------------ | ----------------------------------------------------------------------------------------- |
| `name`                  | ✅ Yes       | The unique name of the remediation task.                                                  |
| `policyAssignmentId`    | ✅ Yes       | The resource ID of the policy assignment this remediation is linked to.                   |
| `scope`                 | ✅ Yes       | The scope (subscription, resource group, etc.) where the remediation runs.                |
| `resourceDiscoveryMode` | No           | How resources are discovered: `ExistingNonCompliant` (default) or `ReEvaluateCompliance`. |
| `failureThreshold`      | No           | Number of failed resources allowed before the remediation stops.                          |
| `description`           | No           | Optional human-readable description of the remediation task.                              |
| `createdOn`             | No           | Timestamp when the remediation was created (read-only).                                   |
| `lastModifiedOn`        | No           | Timestamp of last modification (read-only).                                               |
| `filters`               | No           | Optional filters to scope remediation to certain resources.                               |
| `metadata`              | No           | Optional metadata for organizational purposes.                                            |

## Evaluation Outcomes

The following are the times or events that cause a resource to be evaluated:

- A resource is created or updated in a scope with a policy assignment.
- A scope gets a new assignment of a policy or initiative.
- A policy or initiative already assigned to a scope is updated.
- The standard compliance evaluation cycle that occurs once every 24 hours.

### Trigger a manual policy scan

We can trigger a manual policy scan using the REST API, Azure CLI, or Azure Powershell.

**REST API**
We can execute the post request in the following documentation: https://learn.microsoft.com/en-us/rest/api/policy/policy-states/trigger-subscription-evaluation?view=rest-policy-2019-10-01&tabs=HTTP

**Azure CLI:**
az policy state trigger-scan --resource-group "resourceGroupName"

**Azure PowerShell**
Start-AzPolicyComplianceScan -ResourceGroupName 'resourceGroupName'

### Array properties evaluation

In Azure Policy, some fields (aliases) return arrays instead of single values.
For example:

- A Network Security Group (Microsoft.Network/networkSecurityGroups) has an array of security rules.

#### Syntax:

```
"count([field('<arrayAlias>')]) <comparisonOperator> <number>"
"count([field('<arrayAlias>[?(@.<property> == <value>)]')]) <comparison> <number>" #This one is a filtered array.
```

## Control Plane vs Data Plane
