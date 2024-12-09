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

output registryLoginServer string = containerRegistry.properties.loginServer
output adminUsername string = listCredentials(containerRegistry.id, '2023-01-01-preview').username
output adminPassword string = listCredentials(containerRegistry.id, '2023-01-01-preview').passwords[0].value
