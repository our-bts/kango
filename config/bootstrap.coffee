fs = require("fs")
express = require('express')
cors = require('cors')
errorHandler = require('errorhandler')
morgan  = require('morgan')
bodyParser = require("body-parser")
methodOverride = require("method-override")
domainError = require("../common/domainError")
ms = require("../common/MemoryStore").MemoryStore
config = require("./config")

module.exports = (appPath)->

  errorHandler.title = "Kango"
  app = express()
  app.use bodyParser.urlencoded({limit: '10mb', extended: false})
  app.use bodyParser.json({limit: '10mb'})
  app.use methodOverride()
  app.use cors()
  app.use morgan("short")
  app.use domainError()

  #注册express route
  routes_path = appPath + "/" + config.configInfo.routesFolder
  fs.readdirSync(routes_path).forEach (file) ->
    newPath = routes_path + "/" + file
    stat = fs.statSync(newPath)
    if stat.isFile()
      if (/(.*)\.(js$)/.test(file))
        require(newPath)(app)


  app.use errorHandler()
  app