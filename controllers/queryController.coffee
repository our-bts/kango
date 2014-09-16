dbFactory = require("../db/dbFactory").factory
util = require("../common/util")

exports.query = (req, res, next)->
  queryOption = util.parseQueryString(req.query)
  dbFactory.getCollection req.cloudReq.db, req.cloudReq.collection, (error, col)->
    if error?
      next error
    else
      query = queryOption.filter
      result = util.buildQueryReturnObj(queryOption)
      col.find(query, queryOption).toArray (error, rows)->
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
  queryOption = util.parseQueryString(req.query)
  dbFactory.getCollection req.cloudReq.db, req.cloudReq.collection, (error, col)->
    if error?
      next error
    else
      query = util.getCriteriaForQueryId(req.cloudReq.data)
      option =
        fields: queryOption.fields
      col.findOne query, option, (error, row)->
        if error?
          next error
        else
          if row?
            res.json row
          else
            res.send(null)