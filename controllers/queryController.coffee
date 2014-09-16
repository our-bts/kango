dbFactory = require("../db/dbFactory").factory
util = require("../common/util")

exports.query = (req, res, next)->
  req.queryOption = util.parseQueryString(req.query)
  dbFactory.getCollection req.cloudReq.db, req.cloudReq.collection, (error, col)->
    if error?
      next error
    else
      query = req.queryOption.filter
      result = util.buildQueryReturnObj(req)
      col.find(query, req.queryOption).toArray (error, rows)->
        if error?
          next error
        else
          result.rows = rows
          col.count query, (error, count)->
            if error?
              next error
            else
              result.total_rows = count
              res.json result


exports.queryById = (req, res, next)->
  req.queryOption = util.parseQueryString(req.query)
  dbFactory.getCollection req.cloudReq.db, req.cloudReq.collection, (error, col)->
    if error?
      next error
    else
      query = util.getCriteriaForQueryId(req.cloudReq.data)
      option =
        fields: req.queryOption.fields
      col.findOne query, option, (error, row)->
        if error?
          next error
        else
          if row?
            res.json row
          else
            res.send(null)