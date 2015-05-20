util = require 'util'
request = require 'superagent'
koa = require 'koa'
router = require('koa-router')()
bodyParser = require 'koa-bodyparser'
json = require 'koa-json'

class master
  constructor: (@que, @salves)  ->
    unless util.isArray @salves then throw new Error "【Que】#{@name}: salves必须为数组"

  distribute: (task) ->
    new Promise (resolve, reject) =>
      salve = @salves.shift()
      request
      .post salve + '/process'
      .send task
      .set 'Accept', 'application/json'
      .end (err, res) ->
        if err then reject err
        if res.status == 200
          res.text = JSON.parse res.text
          resolve res.text.result
        else
          reject res.text
      @salves.push salve

  listen: (port) ->
    server = koa()
    server.use bodyParser()
    server.use json()
    ctx = @
    router.post '/task', () ->
      value = @request.body
      ctx.que.push value
      yield @body = {message: 'ok!'}

    router.get '/task/processed', () ->
      numOfProcessed = ctx.que.getNumberOfProcessed()
      yield @body = {processed: numOfProcessed}

    router.get '/task/rejected', () ->
      numOfRejected = ctx.que.getNumberOfRejected()
      yield @body = {rejected: numOfRejected}

    server.use router.routes()
    server.use router.allowedMethods()
    server.listen port

module.exports = master