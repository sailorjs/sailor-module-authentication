## -- Dependencies -------------------------------------------------------------

jwt         = require 'jsonwebtoken'
sailor      = require 'sailorjs'
translate   = sailor.translate
errorify    = sailor.errorify
tokenConfig = sails.config.authentication.token

existValue = (array, value) ->
  if (array.indexOf(value) > -1) then true else false

isEndpoint = (req) ->
  requestPath         = req._parsedOriginalUrl.pathname.toLowerCase()
  sanetizeRequestPath = requestPath.substring(1)
  requestMethod       = req.route.method.toLowerCase()
  endpoints           = tokenConfig.endpoints

  endpoint =  unless endpoints[sanetizeRequestPath]? then false else existValue(endpoints[sanetizeRequestPath], requestMethod)
  sails.log.debug "Token verification :: path [#{requestPath}], method [#{requestMethod}], endpoint [#{endpoint}] :: valid [true]"
  endpoint

## -- Exports -------------------------------------------------------------

module.exports = (req, res, next) ->

  return next() if isEndpoint(req)

  token = undefined
  if req.method is "OPTIONS" and req.headers.hasOwnProperty("access-control-request-headers")
    hasAuthInAccessControl = !!~req.headers["access-control-request-headers"].split(",").map((header) ->
      header.trim()
    ).indexOf("authorization")
    return next() if hasAuthInAccessControl

  if req.headers and req.headers.authorization
    parts = req.headers.authorization.split(" ")
    if parts.length is 2
      scheme      = parts[0]
      credentials = parts[1]
      token       = credentials  if /^Bearer$/i.test(scheme)
    else
      return errorify
      .add 'domain', translate.get("Token.BadFormat"), 'token'
      .end res, 'badRequest'
  else
    return errorify
    .add 'domain', translate.get("Token.NotFound"), 'token'
    .end res, 'badRequest'

  JWTService.decode token, (err, decoded) ->
    if (err)
      if err.name is 'TokenExpiredError'
        return errorify
        .add 'domain', translate.get("Token.Expired"), 'token'
        .end res, 'badRequest'
      else
        return res.badRequest(errorify.serialize(err))
    else
      req.token = decoded
      if decoded.user.id?
        User.findOne(decoded.user.id).populateAll().exec (err, user) ->
          if err then req.user = null else req.user = user
          next()
      else
        next()
