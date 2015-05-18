koa = require 'koa'
co = require 'co'
router = require('koa-router')()
bodyParser = require 'koa-bodyparser'
json = require 'koa-json'

salve = (handler) ->
  server = koa()
  server.use bodyParser()
  server.use json()

  router.post '/process', () ->
    yield task = @request.body
    result = yield handler task
    yield @body = {statusCode: 0, info: '处理成功，返回结果', result: result}
#    co.call @, () ->
#      result = yield handler task
#      yield @body = {statusCode: 0, info: '处理成功，返回结果', result: result}
#      if result
#        @status = 200
#        yield @body = {statusCode: 0, info: '处理成功，返回结果', result: result}
#    .then ((result) ->
#      console.log '1'
#      console.log "get result! result is #{result}"
#      yield @body = {statusCode: 0, info: '处理成功，返回结果', result: result}
#    ).bind @
#    .catch ((error) ->
#      console.log '2'
#      yield @body = {statusCode: 1, info: '处理出错', result: error}
#    ).bind @

  server.use router.routes()
  server.use router.allowedMethods()
  server

module.exports = salve