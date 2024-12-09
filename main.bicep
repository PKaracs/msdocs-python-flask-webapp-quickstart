param acrName string
param acrLocation string
param servicePlanName string
param servicePlanLocation string
param webAppName string
param webAppLocation string
param containerRegistryImageName string
param containerRegistryImageVersion string

module acrModule './modules/acr.bicep' = {
  name: 'deployACR'
  params: {
    name: acrName
    location: acrLocation
    acrAdminUserEnabled: true
  }
}

module servicePlanModule './modules/servicePlan.bicep' = {
  name: 'deployServicePlan'
  params: {
    name: servicePlanName
    location: servicePlanLocation
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
  }
}

module webAppModule './modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: webAppName
    location: webAppLocation
    kind: 'app'
    serverFarmResourceId: servicePlanModule.outputs.servicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrModule.outputs.registryLoginServer}/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: acrModule.outputs.registryLoginServer
      DOCKER_REGISTRY_SERVER_USERNAME: acrModule.outputs.adminUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: acrModule.outputs.adminPassword
    }
  }
}
