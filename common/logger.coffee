log4js = require("log4js")

infoLogger = log4js.getLogger("info")
errorLogger = log4js.getLogger("errors")
defaultLogger = log4js.getLogger()

exports.log = (args)->
  infoLogger.info args

exports.error = (args)->
  errorLogger.error args

exports.consoleLog = (args) ->
  defaultLogger.debug args