param name string
param location string = resourceGroup().location
param tags object = {}




resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'S1'
    capacity: 1
  }
 
}

output id string = appServicePlan.id



