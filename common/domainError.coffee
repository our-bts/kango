domain = require("domain")
module.exports = ->
  (req, res, next) ->
    d = domain.create()
    d.add req
    d.add res
    d.on "error", (err)->
      d._throwErrorCount = (d._throwErrorCount || 0) + 1
      if (d._throwErrorCount > 1)
        return
      res.setHeader("Connection", "close")
      next err

    d.run next