# This script deploys an ARM template to create some resources with
# different features that ARM templates have.

$rg = "RG-ARM-ramp-up"

# Remove Resource group if it already exists
if (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue) {
  Write-Output "Resource group $rg already exists. Deleting it..."
  Remove-AzResourceGroup -Name $rg -Force
}

# Create a new Resource group
Write-Output "Creating resource group $rg..."
New-AzResourceGroup -Name $rg -Location "Canada Central"

# Deploy the ARM template
Write-Output "Deploying ARM template"
New-AzResourceGroupDeployment `
  -Name "arm-deployment" `
  -ResourceGroupName $rg `
  -TemplateFile "./arm-template.json" `
  -Verbose
