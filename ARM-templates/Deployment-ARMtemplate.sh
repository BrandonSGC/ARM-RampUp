# This script deploys an ARM template to create some resources with
# different features that ARM templates have.

rg="RG-ARM-ramp-up"
location="canadacentral"
templateFile="./arm-template.json"

# Check if the resource group exists
rgExists=$(az group exists --name "$rg") # The az group exists command returns a string with "true" or "false"

if [ "$rgExists" == "true" ]; then
  echo "Resource group $rg already exists. Deleting it..."
  az group delete --resource-group "$rg" --yes --no-wait
  echo "Waiting for resource group to be deleted..."
  az group wait --name "$rg" --deleted
else
  echo "Resource group $rg does not exist. Continuing..."
fi

# Create the resource group
echo "Creating resource group $rg..."
az group create --name "$rg" --location "$location"

# Deploy the ARM template
echo "Deploying ARM template..."
az deployment group create \
  --name "arm-deployment" \
  --resource-group "$rg" \
  --template-file "$templateFile" \
  --verbose