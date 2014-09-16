dbFactory = require("../db/dbFactory").factory
util = require("../common/util")
ms = require("../common/MemoryStore").MemoryStore
_ = require('lodash')
async = require("async")

exports.updateFields = (req, res, next)->
  cloudReq = req.cloudReq
  db = cloudReq.db
  collection = cloudReq.collection
  newFields = cloudReq.fields
  if cloudReq.isRemove is true
    ms.delSchema "#{db}_#{collection}"
    res.send 201
  else
    ms.getSchema "#{db}_#{collection}", (err, fields)->
      if err?
        next err
      else
        oldFields = fields

        changedFields = getChangedIndexes newFields, oldFields

        if changedFields.length is 0
          res.send 200
          return

        prepareForHandler changedFields

        dbFactory.getCollection db, collection, (err, col)->
          if err?
            next err
          else
            async.mapSeries changedFields, (item, callback)->
              if item.updateType is "delete"
                col.dropIndex "#{item.FieldName}_1", callback
              else
                col.ensureIndex item,
                  background: true
                  dropDups: true
                  w: 1
                , callback
            , (error, results)->
              if error?
                next(error)
              else
                ms.setSchema "#{db}_#{collection}", newFields
                res.json results

prepareForHandler = (changedFields)->
  if _.some(changedFields, {"updateType": "new"}) is false
    return
  else
    newFields = _.remove changedFields, (i) ->
      return i.updateType is "new"
    for item in newFields
      obj = {}
      obj[item.FieldName]= 1
      changedFields.push obj



getChangedIndexes = (newFields, oldFields)->
  results = []
  if not oldFields?
    for k, v of newFields
      fc = _.cloneDeep(v)
      fc.updateType = "new"
      results.push fc

    return results

  newHash = util.getHash JSON.stringify newFields
  oldHash = util.getHash JSON.stringify oldFields
  if newHash is oldHash
    return []

  for k, v of newFields
    if not oldFields[k]?
      fc = _.cloneDeep(v)
      fc.updateType = "new"
      results.push fc

  for k, v of oldFields
    if not newFields[k]?
      fc = _.cloneDeep(v)
      fc.updateType = "delete"
      results.push fc

  return results


exports.updateDbInfo = (req, res, next)->
  cloudReq = req.cloudReq
  db = cloudReq.db
  dbInfo = cloudReq.dbInfo
  if cloudReq.isRemove is true
    ms.delDbInfo db
  else
    ms.setDbInfo db, dbInfo
  res.send(201)