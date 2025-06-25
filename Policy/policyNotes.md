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

- **All**: Evaliate resource groups, subscriptions, and all resources.
- **Indexed**: only evaluate resource tupes that support tags and locations.

## Policy Effects
Each policy definition in Azure Policy has a single *effect* in its *policyRule*. That effect determines what happens when the policy rule is evaluated to match. The effects behave differently if they are for a new resource, an updated resource, or an existing resource.

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

