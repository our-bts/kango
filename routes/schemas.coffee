schemaController = require("../controllers/schemaController")
config = require("../config/config").configInfo
validator = require("../common/validator")
module.exports = (app) ->
  app.put "#{config.metaAddress}/schema"
  , validator.validatorForUpdateIndex
  , (req, res, next)->
    req.params.db = req.cloudReq.db
    next()
  , validator.validatorDBStatus
  , schemaController.updateFields

  app.put "#{config.metaAddress}/dbInfo"
  , validator.validatorForUpdateDbInfo
  , schemaController.updateDbInfo
