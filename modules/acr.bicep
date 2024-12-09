param name string
param location string
param acrAdminUserEnabled bool

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

@description('The login server URL for the container registry')
output registryLoginServer string = containerRegistry.properties.loginServer

@secure()
output adminUsername string = containerRegistry.listCredentials().username

@secure()
output adminPassword string = containerRegistry.listCredentials().passwords[0].value
