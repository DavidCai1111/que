co = require 'co'
Redis = require './redis'
BasicQue = require './BasicQue'
Task = require './Task'

class Que extends BasicQue
  constructor: (@name = 'anonymous queue') ->
    super @name
    @redis = Redis.createClient()

  push: (value) ->
    if typeof value == 'function' then throw new Error "【Que】#{@name}: 传入的队列的必须是基本值或非函数对象"
    unless @redis then throw new Error "【Que】#{@name}: 这个任务队列已经关闭"

    co.call @, () ->
      if @highWaterMark != 0 && (@highWaterMark <= (yield @getQueLength())) then return
      value = JSON.stringify new Task value

      @redis.rpush [@name, value], ((err) ->
        if err then reject err
        @emitter.emit 'push', value
      ).bind @

  shift: () ->
    new Promise ((resolve, reject) ->
      @redis.lpop [@name], (err, result) ->
        if err then reject err
        result = JSON.parse result
        resolve result
    ).bind @

  getQueLength: () ->
    new Promise ((resolve, reject) ->
      @redis.llen [@name], (err, length) ->
        if err then reject err
        resolve length
    ).bind @

  stop: () ->
    @redis.lrem [@name,0,-1], ((err, nRemoved) ->
      Redis.releaseClient @redis
      @end = true
      console.log "【Que】#{@name}: 清空队列并退出！清空了队列中剩余的#{nRemoved}个元素"
    ).bind @

module.exports = Que