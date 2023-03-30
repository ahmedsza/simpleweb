param name string
param location string = resourceGroup().location
param tags object = {}

// Reference Properties
param applicationInsightsName string = ''
param appServicePlanId string





resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  tags: tags
  location: location
  identity: {
    type: 'SystemAssigned'
  }

  dependsOn: [
    applicationInsights
  ]
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }



  }

  resource appServiceLogging 'Microsoft.Web/sites/config@2020-06-01' = {
    parent: appService
    name: 'appsettings'
    properties: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
    }
    dependsOn: [
      appServiceSiteExtension
    ]
  }
  
  resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
    parent: appService
    name: 'Microsoft.ApplicationInsights.AzureWebSites'
    dependsOn: [
      applicationInsights
    ]
  }
  
  resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
    parent: appService
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Warning'
        }
      }
      httpLogs: {
        fileSystem: {
          retentionInMb: 40
          enabled: true
        }
      }
      failedRequestsTracing: {
        enabled: true
      }
      detailedErrorMessages: {
        enabled: true
      }
    }
  }


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
