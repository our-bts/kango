dbFactory = require("../db/dbFactory").factory
lru = require("lru-cache")
logger = require("./logger")

###
  kType: dbInfo or schema
###
class MemoryStore
  constructor: ->
    options =
      max: 2000
      maxAge: 5 * 60 * 1000
    @cache = lru(options)

  setDbInfo: (key, value)->
    @set(key, value, "dbInfo")

  setSchema: (key, value)->
    @set(key, value, "schema")

  set: (key, value, kType) ->
    @cache.set key, value
    @save(key, value, kType)

  getDbInfo: (key, callback)->
    @get(key, callback, "dbInfo")

  getSchema: (key, callback)->
    @get(key, callback, "schema")

  get: (key, callback, kType) ->
    value = @cache.get key
    if value?
      callback(null, value)
    else
      criteria =
        _id: key
      self = this
      dbFactory.getCollection "kango", kType, (err, col)->
        if err?
          logger.error err
        else
          col.findOne criteria, (error, schema)->
            if error?
              callback(error, null)
            else if not schema?
              callback(null, null)
            else
              self.cache.set key, schema.value
              callback(null, schema.value)

  save: (key, value, kType)->
    criteria =
      _id: key
    data =
      _id: key
      key: key
      value: value
    dbFactory.getCollection "kango", kType, (error, col)->
      if error?
        logger.error error
      else
        col.update criteria, data,
          upsert: true
          w: 1
        , (error, result)->
          if error?
            logger.error error


  delDbInfo: (key)->
    @del(key, "dbInfo")

  delSchema: (key)->
    @del(key, "schema")

  del: (key, kType) ->
    criteria =
      _id: key
    self = this
    dbFactory.getCollection "cloudData", kType, (err, col)->
      if err?
        logger.error err
      else
        col.remove criteria,
          w:1
        , (error, numberOfRemovedDocs)->
          if error?
            logger.error error
          else
            self.cache.del key

resultStore = new MemoryStore()
exports.MemoryStore = resultStore
