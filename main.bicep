@description('Required. Name of your Azure Container Registry.')
@minLength(5)
@maxLength(50)
param name string

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = true

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('The name of the App Service')
param appServiceName string

@description('The name of the container image')
param containerRegistryImageName string = 'PeterAppRegistry'

@description('The version/tag of the container image')
param containerRegistryImageVersion string = 'latest'

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'myKeyVault'
    location: location
    enableVaultForDeployment: true
  }
}

// Reference the Key Vault
var keyVaultReference = keyVault.outputs.keyVaultId

// Pass secrets to the container registry module
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    name: name
    location: location
    acrAdminUserEnabled: acrAdminUserEnabled
    adminCredentialsKeyVaultResourceId: keyVaultReference
    adminCredentialsKeyVaultSecretUserName: 'acr-username'
    adminCredentialsKeyVaultSecretUserPassword1: 'acr-password1'
    adminCredentialsKeyVaultSecretUserPassword2: 'acr-password2'
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlanPeter'
  params: {
    name: 'appServicePlanPeter'
    location: location
    sku: {
      name: 'B1'
      capacity: 1
      family: 'B'
      size: 'B1'
      tier: 'Basic'
    }
  }
}

module appService 'modules/app-service.bicep' = {
  name: 'appServicePeter'
  params: {
    name: appServiceName
    location: location
    appServicePlanName: appServicePlan.name
    containerRegistryName: name
    containerRegistryImageName: containerRegistryImageName
    containerRegistryImageVersion: containerRegistryImageVersion
  }
}

output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output appServiceId string = appService.outputs.id
output appServiceName string = appService.outputs.name
output appServiceDefaultHostName string = appService.outputs.defaultHostName
