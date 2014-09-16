configInfo = {}

nodeConfig =
  listenPort: 8401
  mongodbAddress: "mongodb://10.16.75.23,10.16.75.25,10.16.75.26/{db}?replicaSet=NeweggCloud&connectTimeoutMS=60000"
  metaAddress: "/kango"
  kangoAddress: "/kango/:db/:collection"
  routesFolder: "routes"

initConfig = ->
  configInfo = nodeConfig
  configInfo

exports.configInfo = initConfig()
