ms = require("./MemoryStore").MemoryStore
util = require("./util")
operationController = require("../controllers/operationController")
config = require("../config/config").configInfo


exports.validatorDBStatus = (req, res, next) ->
  db = req.params.db
  ms.getDbInfo db, (err, dbInfo)->
    if err?
      next(err)
    else
      if not dbInfo?
        error = new Error()
        error.message = "Database not exists"
        error.status = 400
        next error
      else if dbInfo.Status.toLowerCase() isnt "active"
        error = new Error()
        error.message = "Database can not use now"
        error.status = 400
        next error
      else
        next()

validatorForSingleSave = exports.validatorForSingleSave = (req, res, next) ->
  body = req.body
  db = req.params.db
  collection = req.params.collection
  isSchemaExists db, collection, (err, f)->
    if err?
      next(err)
    else
      fields = f
      try
        isBodyObject(body)
        ensurePrimary(body, fields)
        req.cloudReq =
          db: db
          collection: collection
          data: body
          fields: fields
        next()
      catch error
        next error


validatorForSingleDelete = exports.validatorForSingleDelete = (req, res, next) ->
  db = req.params.db
  collection = req.params.collection
  isSchemaExists db, collection, (err, f)->
    if err?
      next(err)
    else
      fields = f
      try
        req.cloudReq =
          db: db
          collection: collection
          data:
            _id: req.params.id
          fields: fields
        next()
      catch error
        next error

validatorForBatchInsert = exports.validatorForBatchInsert = (req, res, next) ->
  body = req.body
  db = req.params.db
  collection = req.params.collection

  isSchemaExists db, collection, (err, f)->
    if err?
      next(err)
    else
      fields = f
      try
        isBodyArray(body)
        ensurePrimary(item, fields) for item in body
        req.cloudReq =
          db: db
          collection: collection
          data: body
          fields: fields
        next()
      catch error
        next error

exports.validatorForQuery = (req, res, next) ->
  db = req.params.db
  collection = req.params.collection
  isSchemaExists db, collection, (err, f)->
    if err?
      next(err)
    else
      fields = f
      try
        req.cloudReq =
          db: db
          collection: collection
          fields: fields
        req.cloudReq.data = {_id: req.params.id} if req.params.id?
        next()
      catch error
        next error

exports.validatorForAdmin=(req, res, next)->
  db = req.params.db || "admin"
  collection = req.params.collection
  req.cloudReq =
    db: db
    collection: collection
  next()

isSchemaExists = (db, collection, callback)->
  ms.getSchema "#{db}_#{collection}", (err, schema)->
    if err?
      callback(err, null)
    else if not schema?
      error = new Error()
      error.message = "No schema defined"
      error.status = 400
      callback error, null
    else
      callback null, schema

isBodyObject = (data)->
  if util.is("Object", data) is false
    error = new Error("Only object supported")
    error.status = 400
    throw error

isBodyArray = (data)->
  if util.is("Array", data) is false or data.length is 0
    error = new Error("Only array supported")
    error.status = 400
    throw error

ensurePrimary = (data, fields)->
  primaryField = v for p,v of fields when v.IsPrimaryKey is true
  if not primaryField?
    error = new Error("No primary key defined")
    error.status = 400
    throw error
  if data.hasOwnProperty(primaryField.FieldName) is false
    error = new Error("Input data must have primary field")
    error.status = 400
    throw error
  data._id = data[primaryField.FieldName]


exports.validatorForUpdateIndex=(req, res, next)->
  newSchema = req.body
  try
    isSchemaBodyCorrect(newSchema)
    removeUnIndexFields(newSchema) if newSchema.IsRemove is false
    req.cloudReq =
      db: newSchema.DB
      collection: newSchema.Schema
      isRemove: newSchema.IsRemove
      fields: transferFields(newSchema.Fields)
    next()
  catch error
    next error

isSchemaBodyCorrect = (schema)->
  if not schema.DB? or not schema.Schema?
    error = new Error("Bad request")
    error.status = 400
    throw error
  if schema.IsRemove is false
    if not schema.Fields? or util.is("Array", schema.Fields) is false or schema.Fields.length is 0
      error = new Error("Bad request")
      error.status = 400
      throw error

removeUnIndexFields = (schema)->
  result = (item for item in schema.Fields when item.IsIndex is true)
  if result.length is 0
    error = new Error("No primary key defined")
    error.status = 400
    throw error
  schema.Fields = result

transferFields = (fields)->
  result = {}
  fields = fields || []
  for f in fields
    result[f.FieldName] = f

  return result


exports.validatorForUpdateDbInfo=(req, res, next)->
  newDbInfo = req.body
  try
    if not newDbInfo.DB?
      error = new Error("Bad request")
      error.status = 400
      throw error
    if newDbInfo.IsRemove is false
      if not newDbInfo.Status?
        error = new Error("Bad request")
        error.status = 400
        throw error

    req.cloudReq =
      db: newDbInfo.DB
      isRemove: newDbInfo.IsRemove
      dbInfo: newDbInfo
    next()
  catch error
    next error