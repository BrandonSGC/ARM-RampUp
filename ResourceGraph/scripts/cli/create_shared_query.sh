az graph shared-query create --name "Summarize resources by location" --description "This shared query summarizes resources by location for a pinnable map graphic." --graph-query "Resources | summarize count() by location" --resource-group "MyResources"

