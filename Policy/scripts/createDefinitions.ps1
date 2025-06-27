# Define list of policies to create
$policiesDefinitions = @(
  @{ 
    name        = 'AuditStorageAccounts'; 
    displayName = 'Audit Storage Accounts not using HTTPS'; 
    path        = 'C:/Users/brans/Desktop/Engineering/arm-ramp-up/Policy/audit.json' 
  },
  @{ 
    name        = 'AuditVMsWithoutDiagnostics';
    displayName = 'Audit VMs without diagnostic settings';
    path        = 'C:/Users/brans/Desktop/Engineering/arm-ramp-up/Policy/auditIfNotExists.json' 
  },
  @{ 
    name        = 'AppendTagResourceGroups';
    displayName = 'Append a tag and its value to new resource groups';
    path        = 'C:/Users/brans/Desktop/Engineering/arm-ramp-up/Policy/append.json' 
  },
  @{ 
    name        = 'DenyUnsupportedRegion';
    displayName = 'Deny VM deployments outside approved regions';
    path        = 'C:/Users/brans/Desktop/Engineering/arm-ramp-up/Policy/deny.json' 
  },
  @{ 
    name        = 'EnforceTagEnvironmentDev';
    displayName = 'Enforce tag "environment=dev"';
    path        = 'C:/Users/brans/Desktop/Engineering/arm-ramp-up/Policy/modify.json' 
  },
  @{ 
    name        = 'DeployDiagnosticSettingsStorageAccounts';
    displayName = 'Deploy diagnostic settings to Storage Accounts';
    path        = 'C:/Users/brans/Desktop/Engineering/arm-ramp-up/Policy/deployIfNotExists.json' 
  }
)

# Create each policy
foreach ($policy in $policiesDefinitions) {
  New-AzPolicyDefinition `
    -Name $policy.name `
    -DisplayName $policy.displayName `
    -Policy $policy.path `
    -Verbose
}