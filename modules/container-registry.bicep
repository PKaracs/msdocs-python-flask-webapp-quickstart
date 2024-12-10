@description('The name of the Azure Container Registry')
param name string

@description('The location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool = true

@description('Resource ID of the Key Vault for storing admin credentials')
param adminCredentialsKeyVaultResourceId string

@description('Admin username for the Azure Container Registry')
@secure param adminCredentialsKeyVaultSecretUserName string

@description('Admin password for the Azure Container Registry')
@secure param adminCredentialsKeyVaultSecretUserPassword1 string

@secure param adminCredentialsKeyVaultSecretUserPassword2 string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    keyVaultProperties: {
      secretName: adminCredentialsKeyVaultSecretUserName
      secretPassword: adminCredentialsKeyVaultSecretUserPassword1
      secretPassword2: adminCredentialsKeyVaultSecretUserPassword2
    }
  }
}

// Store credentials in Key Vault
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

resource secretAdminPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

resource secretAdminPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword2
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

output loginServer string = containerRegistry.properties.loginServer
