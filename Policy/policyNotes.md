# Policy Notes

## Evaluation Outcomes

## Structure of a Policy Definition

| Component     | Description                                        |
| ------------- | -------------------------------------------------- |
| `name`        | Name of the policy definition                      |
| `type`        | Always `Microsoft.Authorization/policyDefinitions` |
| `displayName` | Friendly name                                      |
| `description` | What the policy does                               |
| `mode`        | All or Indexed                                     |
| `parameters`  | Input values for customizing behavior              |
| `policyRule`  | The logic (if-then structure)                      |
| `metadata`    | Optional tags like version, category, etc.         |

### Important things to know about mode property:

The mode is configured depending on if the policy is targeting an Azure Resource Manager property or a Resource Provider property

#### Resource Manager Modes

- **All**: Evaluate resource groups, subscriptions, and all resources.
- **Indexed**: only evaluate resource types that support tags and locations.

## Policy Effects

Each policy definition in Azure Policy has a single _effect_ in its _policyRule_. That effect determines what happens when the policy rule is evaluated to match. The effects behave differently if they are for a new resource, an updated resource, or an existing resource.

| Effect              | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| `deny`              | Blocks deployment if non-compliant                           |
| `audit`             | Logs non-compliant resources                                 |
| `auditIfNotExists`  | Audits only if related resource doesn't exist                |
| `deployIfNotExists` | Automatically deploys a related resource if it doesn’t exist |
| `append`            | Adds fields to a resource during deployment                  |
| `disabled`          | Policy exists but doesn't do anything                        |
| `modify`            | Alters a request during creation                             |
| `addToNetworkGroup` |                                                              |
| `denyAction`        |                                                              |
| `manual`            |                                                              |
| `mutate`            |                                                              |

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
