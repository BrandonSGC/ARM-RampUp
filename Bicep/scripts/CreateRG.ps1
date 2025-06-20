param (
  [string] $rgName,
  [string] $rgLocation
)

Write-Host "Creating resource group: $rgName in $rgLocation"
$rg = New-AzResourceGroup -Name $rgName -Location $rgLocation

$DeploymentScriptOutputs = @{
  rgName = $rg.ResourceGroupName
}
