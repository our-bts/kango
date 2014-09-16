adminController = require("../controllers/adminController")
config = require("../config/config").configInfo
validator=require("../common/validator")

module.exports = (app) ->
  app.get "#{config.metaAddress}/db", validator.validatorForAdmin, adminController.getAllDbNames
  app.get "#{config.metaAddress}/:db/collection", validator.validatorForAdmin, adminController.getAllCollectionNames
  app.get "#{config.metaAddress}/:db/status", validator.validatorForAdmin, adminController.getDbStatus
  app.get "#{config.kangoAddress}/status", validator.validatorForAdmin, adminController.getCollectionStats
  app.get "#{config.kangoAddress}/index", validator.validatorForAdmin, adminController.getCollectionIndex
  app.get "#{config.metaAddress}/replset-status", validator.validatorForAdmin, adminController.getReplSetStatus
  app.get "#{config.metaAddress}/server-status", validator.validatorForAdmin ,adminController.getServerStatus