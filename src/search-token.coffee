http          = require 'http'
_             = require 'lodash'
TokenManager = require 'meshblu-core-manager-token'

class SearchToken
  constructor: ({@datastore, @uuidAliasResolver, @pepper}) ->
    @tokenManager = new TokenManager {@datastore, @uuidAliasResolver, @pepper}

  do: (request, callback) =>
    {fromUuid, auth, projection} = request.metadata
    fromUuid ?= auth.uuid

    try
      query = JSON.parse request.rawData
    catch error
      return callback null, @_getEmptyResponse request, 422

    @tokenManager.search {uuid: fromUuid, query, projection}, (error, tokens) =>
      return callback error if error?
      callback null, @_getTokensResponse request, 200, tokens

  _getEmptyResponse: (request, code) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]

  _getTokensResponse: (request, code, tokens) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
      rawData: JSON.stringify tokens

module.exports = SearchToken
