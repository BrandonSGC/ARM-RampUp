
$rg = "rg-arm-ramp-up"
$location = "Canada Central"

# Create resource group if it doesn't exist
if (-not (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue)) {
  New-AzResourceGroup -Name $rg -Location $location
}

# Note: Ensure you have the Bicep Extension installed: "winget install -e --id Microsoft.Bicep"

# Deploy template
New-AzResourceGroupDeployment `
  -Name BicepDeployment `
  -ResourceGroupName $rg `
  -TemplateFile "./bicep/main.bicep" `
  -Verbose


