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

#disable-next-line outputs-should-not-contain-secrets use-resource-symbol-reference
output adminUsername string = acrAdminUserEnabled ? listCredentials(containerRegistry.id, '2023-01-01-preview').username : ''

#disable-next-line outputs-should-not-contain-secrets
output adminPassword string = acrAdminUserEnabled ? listCredentials(containerRegistry.id, '2023-01-01-preview').passwords[0].value : ''
