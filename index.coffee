config = require("./config/config").configInfo
log4js = require("log4js")
path = require("path")
logger = require("./common/logger")
port = config.listenPort || 8001

log4js.configure path.join(__dirname, "logConfig.json"),
  reloadSecs: 50
  cwd: __dirname

process.on "uncaughtException", (err) ->
  logger.error "[uncaught-error] exception: " + err + "\r\nstack: " + err.stack

app = require("./config/bootstrap")(__dirname)

server = app.listen port, ->
  logger.log("[#{process.pid}] Begin listening on port #{port}")
