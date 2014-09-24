## -- Dependencies -------------------------------------------------------------

jwt       = require 'jsonwebtoken'
sailor    = require 'sailorjs'
translate = sailor.translate
errorify  = sailor.errorify

# path and method when the middleware is not effective
IGNORE_PATHS = ['POST','/user/login','POST','/user']

ignorablePath = (method, path) ->
  # check that the last character is '/' and remove it
  path = path.substring(0, path.length - 1) if path.charAt(path.length-1) is "/"

  for methodPath, index in IGNORE_PATHS by 2
    ignorePath = IGNORE_PATHS[index+1]
    return true if method is methodPath and path is ignorePath
  false

## -- Exports -------------------------------------------------------------

module.exports = (req, res, next) ->
  # TODO: Temporal for development!
  return next() if ignorablePath(req.originalMethod, req.originalUrl)

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
      err = msg: translate.get("Token.BadFormat")
      return res.badRequest(errorify.serialize(err))
  else
    err = msg: translate.get("Token.NotFound")
    return res.badRequest(errorify.serialize(err))

  JWTService.decode token, (err, decoded) ->
    if (err)
      if err.name is 'TokenExpiredError'
        error = msg: translate.get("Token.Expired")
        return res.badRequest(errorify.serialize(error))
      else
        return res.badRequest(errorify.serialize(err))
    else
      req.user = decoded
      next()
