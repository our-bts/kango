dbFactory = require("../db/dbFactory").factory
util = require("../common/util")

exports.save = (req, res, next)->
  cloudReq = req.cloudReq
  criteria = util.getCriteriaForId cloudReq.data
  dbFactory.getCollection cloudReq.db, cloudReq.collection, (error, col)->
    if error?
      next error
    else
      col.update criteria, cloudReq.data,
        upsert: true
        w: 1
      , (error, result)->
        if error?
          next error
        else
          res.send(201)


exports.remove = (req, res, next)->
  cloudReq = req.cloudReq
  criteria = util.getCriteriaForQueryId cloudReq.data
  dbFactory.getCollection cloudReq.db, cloudReq.collection, (error, col)->
    if error?
      next error
    else
      col.remove criteria,
        w: 1
      , (error, result)->
        if error?
          next error
        else
          res.send(201)

exports.batchInsert = (req, res, next)->
  cloudReq = req.cloudReq
  dbFactory.getCollection cloudReq.db, cloudReq.collection, (error, col)->
    if error?
      next error
    else
      col.insert cloudReq.data,
        w: 1
      , (error, result)->
        if error?
          next error
        else
          res.send(201)




