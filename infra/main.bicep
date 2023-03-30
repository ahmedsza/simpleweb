targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param appServicePlanName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param logAnalyticsName string = ''

param resourceGroupName string = ''
param webServiceName string = ''
param serviceName string = 'web'

@description('Id of the user or app to assign application roles')


var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}


module web 'appservice.bicep' = {
  name: 'web'
  scope: rg
  params: {
    appServicePlanId: appServicePlan.outputs.id
    name: !empty(webServiceName) ? webServiceName : '${abbrs.webSitesAppService}web-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
  }
}


module appServicePlan 'appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location

  }
}

module monitoring 'monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output APP_WEB_BASE_URL string = web.outputs.uri
