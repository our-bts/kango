MongoClient = require("mongodb").MongoClient
config = require("../config/config").configInfo
logger = require("../common/logger")
Server = require('mongodb').Server


class ConnectionFactory
  constructor: ->
    @mongoSet = {}
    @connStr = config.mongodbAddress
    @options =
      server:
        logger:
          doDebug: true
          debug: (msg, obj)->
            logger.log "[mongo_debug]: #{msg}"
          log: (msg, obj)->
            logger.log "[mongo_log]: #{msg}"
          error: (msg, obj)->
            logger.log "[mongo_error]: #{msg}"

  getCollection: (dbName, collectionName, callback)->
    self = this
    @getDb dbName, (err, db)->
      if err?
        callback(err, null)
      else
        self.ensureCollection(db, collectionName, callback)

  ensureCollection: (db, collectionName, callback)->
    db.createCollection collectionName, (error, collection)->
      if error?
        logger.error "Get collection Error: #{error}"
        callback(error, null)
      else
        callback(null, collection)


  getDb: (dbName,callback)->
    debugger
    if @mongoSet[dbName]?
      db = @mongoSet[dbName]
      callback null,db
    else
      connectionString = @connStr.replace("{db}", dbName)
      logger.log "[#{process.pid}] Create new connectin for: #{connectionString}"
      self = this
      MongoClient.connect connectionString, @options, (err, db)->
        if err?
          logger.error "Create Connection Error: #{err}"
          callback err,null
        else
          self.mongoSet[dbName] = db
          callback null,db

f = new ConnectionFactory()
exports.factory = f