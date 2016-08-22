_            = require 'lodash'
mongojs      = require 'mongojs'
Datastore    = require 'meshblu-core-datastore'
SearchToken = require '../'

describe 'SearchToken', ->
  @timeout 10000
  beforeEach (done) ->
    @auth = uuid: 'archaeologist'
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)

    database = mongojs 'meshblu-core-task-search-token', ['tokens']
    @datastore = new Datastore
      database: database
      collection: 'tokens'

    database.tokens.remove done

  beforeEach ->
    @pepper = 'im-a-pepper'
    @sut = new SearchToken {@datastore, @uuidAliasResolver, @pepper}

  describe '->do', ->
    beforeEach 'insert auth token', (done)->
      @datastore.insert @auth, done

    describe 'when called without a query', ->
      beforeEach (done) ->
        request =
          metadata:
            auth: @auth
            responseId: 'archaeology-dig-1'
          rawData: ''

        @sut.do request, (error, @response) => done error

      it 'should respond with a 422 code', ->
        expect(@response.metadata.code).to.equal 422

      it 'should respond with an empty array', ->
        expect(@response.rawData).to.not.exist

    describe 'when called with a query', ->
      beforeEach 'insert records', (done)->
        record =
          uuid: 'archaeologist'
          token: 'are-awesome'
          metadata:
            tag: 'smith'
        @datastore.insert [record], done

      beforeEach (done) ->
        query = 'metadata.tag': 'smith'
        request =
          metadata:
            auth: @auth
            responseId: 'archaeology-dig-2'
          rawData: JSON.stringify query

        @sut.do request, (error, @response) => done error

      it 'should respond with a 200 code', ->
        expect(@response.metadata.code).to.equal 200

      it 'should respond with 1 token', ->
        dinosaurTokens = JSON.parse @response.rawData
        expect(dinosaurTokens.length).to.equal 1
