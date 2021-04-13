param functionNamePrefix string = 'func-b-deploy-'
param serverfarms_ASP_name string = 'ASP-Win-Net5-bdemo'
param storageNamePrefix string = 'stfsbdemo'
param repoUrl string = 'https://github.com/fsaleemm/deployfunction.git'

var storageAccounts_name_var = concat(toLower(storageNamePrefix), uniqueString(resourceGroup().id))
var function_app_name_var = concat(toLower(functionNamePrefix), uniqueString(resourceGroup().id))

resource serverfarms_ASP_name_resource 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: serverfarms_ASP_name
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  properties: {}
}

resource storageAccounts_name 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccounts_name_var
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'Storage'
}

resource function_app_name 'Microsoft.Web/sites@2018-11-01' = {
  name: function_app_name_var
  location: resourceGroup().location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverfarms_ASP_name_resource.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts_name_var};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccounts_name.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts_name_var};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccounts_name.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(function_app_name_var)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~10'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
    }
  }
}

resource function_app_name_web 'Microsoft.Web/sites/sourcecontrols@2020-09-01' = {
  name: '${function_app_name.name}/web'
  properties: {
    repoUrl: repoUrl
    branch: 'main'
    isManualIntegration: false
  }
}
