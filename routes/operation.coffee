operationController = require("../controllers/operationController")
config = require("../config/config").configInfo
validator = require("../common/validator")
module.exports = (app) ->
  app.put "#{config.kangoAddress}"
  , validator.validatorDBStatus
  , validator.validatorForSingleSave
  , operationController.save

  app.delete "#{config.kangoAddress}/:id"
  , validator.validatorDBStatus
  , validator.validatorForSingleDelete
  , operationController.remove

  app.post "#{config.kangoAddress}/batch-insert"
  , validator.validatorDBStatus
  , validator.validatorForBatchInsert
  , operationController.batchInsert

