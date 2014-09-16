dbFactory = require("../db/dbFactory").factory

exports.getAllDbNames = (req, res, next)->
  dbName = req.cloudReq.db
  dbFactory.getDb dbName, (err, db)->
    if err?
      next err
    else
      db.admin().listDatabases (err, dbs)->
        if err?
          next err
        else
          res.json dbs.databases

exports.getAllCollectionNames = (req, res, next)->
  dbName = req.cloudReq.db
  dbFactory.getDb dbName, (err, db)->
    if err?
      next err
    else
      db.collectionNames (err, items)->
        if err
          next err
        else
          res.json items

exports.getDbStatus = (req, res, next)->
  dbName = req.cloudReq.db
  dbFactory.getDb dbName, (err, db)->
    if err?
      next err
    else
      db.stats (err, stats)->
        if err?
          next err
        else
          res.json stats

exports.getCollectionStats = (req, res, next)->
  dbName = req.cloudReq.db
  cloName = req.cloudReq.collection
  dbFactory.getCollection dbName, cloName, (err, clo)->
    if err?
      next err
    else
      clo.stats (err, stats)->
        if err?
          next err
        else
          res.json stats

exports.getCollectionIndex = (req, res, next)->
  dbName = req.cloudReq.db
  cloName = req.cloudReq.collection
  dbFactory.getCollection dbName, cloName, (err, clo)->
    if err?
      next err
    else
      clo.indexInformation {full: true}, (err, index)->
        if err?
          next err
        else
          res.json index

exports.getServerStatus = (req, res, next)->
  dbName = req.cloudReq.db
  dbFactory.getDb dbName, (err, db)->
    if err?
      next err
    else
      db.admin().serverStatus (err, info)->
        if err?
          next err?
        else
          res.json info

exports.getReplSetStatus = (req, res, next)->
  dbName = req.cloudReq.db
  dbFactory.getDb dbName, (err, db)->
    if err?
      next err
    else
      db.admin().replSetGetStatus (err, info)->
        if err?
          next err?
        else
          res.json info
