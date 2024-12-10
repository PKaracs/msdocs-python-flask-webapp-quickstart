@description('The name of the Key Vault')
param name string = 'myKeyVault'

@description('The location for the Key Vault')
param location string = 'northeurope'

@description('Enable the Key Vault for deployment')
param enableVaultForDeployment bool = true

@description('Role assignments for the Key Vault')
@secure param roleAssignments array = [
  {
    principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: roleAssignments
  }
}
