redis = require 'redis'
co = require 'co'
BasicQue = require './BasicQue'

class Que extends BasicQue
  constructor: (@name = 'anonymous queue') ->
    super @name
    @redis = redis.createClient()

  push: (value) ->
    ctx = @
    if typeof value == 'function' then throw new Error "#{@name}: 传入的队列的必须是基本值或对象"
    unless @redis then throw new Error "#{@name}: 这个任务队列已经关闭"
    value = JSON.stringify value #确保非基本值类型也可被存储

    new Pormise (resolve, reject) ->
      ctx.redis.rpush [ctx.name, value], (err) ->
        if err then reject err
        ctx.emitter.emit 'push'
        resolve value

  shift: () ->
    ctx = @
    console.log 'shift!'
    new Promise (resolve, reject) ->
      ctx.redis.lpop [ctx.name], (err, result) ->
        if err then reject err
        result = JSON.parse result
        resolve result



module.exports = Que