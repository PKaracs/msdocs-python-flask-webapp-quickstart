param name string
param location string
param sku object

resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  sku: sku
  kind: 'Linux'
  properties: {
    reserved: true
  }
}

output servicePlanId string = servicePlan.id
