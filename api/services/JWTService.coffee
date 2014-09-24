## -- Dependencies -------------------------------------------------------------

jwt         = require 'jsonwebtoken'
tokenConfig = sails.config.token

expirationDate = ->
  expiration = new Date()
  expiration.setDate(expiration.getDate() + tokenConfig.options.expiration / (24 * 60))
  expiration

## -- Exports ------------------------------------------------------------------

module.exports =

  encode: (id) ->
    obj =
      access_token : jwt.sign(id, tokenConfig.secret, tokenConfig.options)
      expire       : expirationDate()
      refresh_token: 'not yet!'

  decode: (token, cb) ->
    jwt.verify token, tokenConfig.secret, tokenConfig.options, (err, decoded) ->
      cb(err, decoded)

  isExpired: (token) ->
    JWTService.decode token, (err, decoded) ->
      return true if err?.name is 'TokenExpiredError'
      false
