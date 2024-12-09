@description('The Azure region for all resources')
param location string = resourceGroup().location

@description('Name of the container registry')
@minLength(5)
@maxLength(50)
param acrName string

@description('Name of the App Service plan')
param servicePlanName string

@description('Name of the web app')
param webAppName string

@description('Name of the container image')
param containerRegistryImageName string

@description('Version/tag of the container image')
param containerRegistryImageVersion string = 'latest'

// Deploy Azure Container Registry
module acrModule './modules/acr.bicep' = {
  name: 'deployACR'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
  }
}

// Deploy App Service Plan
module servicePlanModule './modules/servicePlan.bicep' = {
  name: 'deployServicePlan'
  params: {
    name: servicePlanName
    location: location
    sku: {
      name: 'B1'
      tier: 'Basic'
      size: 'B1'
      family: 'B'
      capacity: 1
    }
  }
}

// Deploy Web App
module webAppModule './modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: webAppName
    location: location
    kind: 'app,linux,container'
    serverFarmResourceId: servicePlanModule.outputs.servicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrModule.outputs.registryLoginServer}/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      alwaysOn: true
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      WEBSITES_PORT: '50505'
      DOCKER_REGISTRY_SERVER_URL: 'https://${acrModule.outputs.registryLoginServer}'
      DOCKER_REGISTRY_SERVER_USERNAME: acrModule.outputs.adminUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: acrModule.outputs.adminPassword
    }
  }
}

output webAppName string = webAppModule.outputs.webAppName
output acrLoginServer string = acrModule.outputs.registryLoginServer
