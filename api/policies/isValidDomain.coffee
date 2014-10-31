## -- Dependencies -------------------------------------------------------------

sailor       = require 'sailorjs'
translate    = sailor.translate
errorify     = sailor.errorify
domainConfig = sails.config.authentication.domain

isValidDomain = (url) ->

  if domainConfig is "*" or domainConfig is url
    validDomain = true
  else
    validDomain = false
    for domain in domainConfig
      if domain is url
        validDomain = true
        break

  sails.log.debug "Domain verification :: url [#{url}], valid [#{validDomain}]"
  validDomain

## -- Exports -------------------------------------------------------------

module.exports = (req, res, next) ->
  unless isValidDomain(req.baseUrl)
    errorify
      .add 'domain', translate.get('Domain.Invalid'), req.baseUrl
      .end res, 'notFound'
  else
    next()
