qs = require("querystring")
crypto = require("crypto")

exports.is = (type, obj)->
  clas = Object.prototype.toString.call(obj).slice(8, -1)
  return obj isnt undefined && obj isnt null && clas is type

exports.getHash = (data) ->
  crypto.createHash("md5").update(data).digest "hex"

exports.randomShuffle = (array)->
  currentIndex = array.length
  while currentIndex isnt 0
    randomIndex = Math.floor(Math.random() * currentIndex)
    currentIndex--
    tempValue = array[currentIndex]
    array[currentIndex] = array[randomIndex]
    array[randomIndex] = tempValue

  array

exports.getCriteriaForQueryId = (data)->
  try
    id = JSON.parse data._id
  catch
    id = data._id
  criteria =
    _id: id
  criteria

exports.getCriteriaForId = (data)->
  criteria =
    _id: data._id
  criteria

exports.buildQueryReturnObj = (req)->
  result =
    pageSize: req.queryOption.limit
    pageIndex: (req.queryOption.skip / req.queryOption.limit) + 1
    total_rows: 0
    rows:[]
  result

exports.parseQueryString = (req)->
  query = {}
  query.limit = 10
  if req.query.pageSize?
    plimit = parseInt(req.query.pageSize)
    if this.is("Number", plimit) and plimit > 0
      query.limit = plimit

  query.skip = 0
  if req.query.pageIndex?
    pIndex = parseInt(req.query.pageIndex)
    if this.is("Number", pIndex) and pIndex > 0
      query.skip = (pIndex - 1) * query.limit

  if req.query.sortField?
    query.sort = []
    pSort = []
    pSort.push req.query.sortField
    sortDirection = if req.query.sort? and req.query.sort is "desc" then "desc" else "asc"
    pSort.push sortDirection
    query.sort.push pSort

  query.fields =
    _id: 0

  if req.query.fields?
    try
      pFields = JSON.parse req.query.fields
      if pFields.length > 0

        for f in pFields
          query.fields[f] = 1
    catch


  query.filter = {}
  for q, v of req.query
    if q.indexOf("f_") is 0
      p = q.replace("f_", "")
      try
        objF = JSON.parse v
      catch
        objF = v
      query.filter[p] = objF

  req.queryOption = query





