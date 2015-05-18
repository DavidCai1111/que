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

  server.use router.routes()
  server.use router.allowedMethods()
  server

module.exports = salve