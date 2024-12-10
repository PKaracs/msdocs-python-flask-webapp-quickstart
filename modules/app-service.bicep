@description('The name of the App Service')
param name string

@description('The location for the App Service')
param location string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the Container Registry')
param containerRegistryName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

@description('Docker registry server URL')
@secure param dockerRegistryServerUrl string

@description('Docker registry server username')
@secure param dockerRegistryServerUserName string

@description('Docker registry server password')
@secure param dockerRegistryServerPassword string

var dockerAppSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}/'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistry.listCredentials().username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
    }
  }
}

output id string = appService.id
output name string = appService.name
output defaultHostName string = appService.properties.defaultHostName

module app_appsettings 'config--appsettings/main.bicep' = if (!empty(appSettingsKeyValuePairs)) {
  name: '${uniqueString(deployment().name, location)}-Site-Config-AppSettings'
  params: {
    appName: app.name
    kind: kind
    storageAccountResourceId: storageAccountResourceId
    appInsightResourceId: appInsightResourceId
    setAzureWebJobsDashboard: setAzureWebJobsDashboard
    appSettingsKeyValuePairs: union(appSettingsKeyValuePairs, dockerAppSettings)
    enableDefaultTelemetry: enableReferencedModulesTelemetry
  }
}
