queryController = require("../controllers/queryController")
config = require("../config/config").configInfo
validator = require("../common/validator")

module.exports = (app)->
  app.get "#{config.kangoAddress}", validator.validatorDBStatus, validator.validatorForQuery, queryController.query
  app.get "#{config.kangoAddress}/:id", validator.validatorDBStatus, validator.validatorForQuery, queryController.queryById
