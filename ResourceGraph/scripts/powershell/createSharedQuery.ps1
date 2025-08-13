$params = @{
  Name = 'Summarize resources by location'
  ResourceGroupName = 'demoSharedQuery'
  Location = 'westus2'
  Description = 'This shared query summarizes resources by location for a pinnable map graphic.'
  Query = 'Resources | summarize count() by location'
}

New-AzResourceGraphQuery @params