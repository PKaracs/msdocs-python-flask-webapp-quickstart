// Parameters
param location string = resourceGroup().location

// Container Registry Parameters
param containerRegistryName string
param acrAdminUserEnabled bool = true

// Service Plan Parameters
param servicePlanName string
var servicePlanSku = {
  name: 'B1'
  tier: 'Basic'
  family: 'B'
  capacity: 1
}

// Web App Parameters
param webAppName string
param dockerRegistryServerUserName string
@secure()
param dockerRegistryServerPassword string
param dockerRegistryImageName string
param dockerRegistryImageVersion string = 'latest'
param webAppCommandLine string = ''

// Deploy Azure Container Registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    name: containerRegistryName
    location: location
    adminUserEnabled: acrAdminUserEnabled
  }
}

// Deploy Azure Service Plan
module servicePlan 'modules/service-plan.bicep' = {
  name: 'servicePlanDeployment'
  params: {
    name: servicePlanName
    location: location
    sku: servicePlanSku
  }
}

// Deploy Azure Web App
module webApp 'modules/web-app.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    appServicePlanId: servicePlan.outputs.id
    dockerRegistryName: containerRegistryName
    dockerRegistryServerUserName: dockerRegistryServerUserName
    dockerRegistryServerPassword: dockerRegistryServerPassword
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageVersion: dockerRegistryImageVersion
    appCommandLine: webAppCommandLine
  }
}

// Outputs
output containerRegistryName string = containerRegistry.outputs.containerRegistryName
output containerRegistryLoginServer string = containerRegistry.outputs.containerRegistryLoginServer
output appServicePlanId string = servicePlan.outputs.id
output webAppHostName string = webApp.outputs.appServiceAppHostName
