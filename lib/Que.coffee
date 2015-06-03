co = require 'co'
Redis = require './redis'
BasicQue = require './BasicQue'
Task = require './Task'
netWork = require './netWork'

class Que extends BasicQue
  constructor: (@name = '匿名队列') ->
    super @name
    @redis = Redis.createClient()

  push: (value) ->
    if typeof value == 'function' then throw new Error "【Que】#{@name}: 传入的队列的必须是基本值或非函数对象"
    unless @redis then throw new Error "【Que】#{@name}: 这个任务队列已经关闭"

    co () =>
      if @highWaterMark != 0 and (@highWaterMark <= (yield @getQueLength())) then return
      value = JSON.stringify new Task value

      @redis.rpush [@name, value], (err) =>
        if err then throw err
        @emitter.emit 'push', value

  shift: () ->
    new Promise (resolve, reject) =>
      @redis.lpop [@name], (err, result) ->
        if err then reject err
        result = JSON.parse result
        resolve result

  getQueLength: () ->
    new Promise (resolve, reject) =>
      @redis.llen [@name], (err, length) ->
        if err then reject err
        resolve length

  process: (task) ->
    co () =>
      if @masterServer != undefined
        result = yield @masterServer.distribute task.data
      else
        result = yield @processor task.data
      @processed += 1
      @running -= 1
      @emit 'done', null, result
    .catch (error) =>
      if task.retryCount > 0
        console.error "【Que】#{@name}: 第#{@processed + 1}个任务出错，错误信息 '#{error.message}' ，开始重试，此任务还剩余的重试次数为#{task.retryCount--}次"
        @process.call @, task
      else
        console.error "【Que】#{@name}: 第#{@processed + 1}个任务出错，错误信息 '#{error.message}' ，错误尝试次数已用尽，放弃此次任务"
        @rejected += 1
        @running -= 1
        @emit 'done', error

  stop: () ->
    @redis.lrem [@name, 0, -1], (err, nRemoved) =>
      Redis.releaseClient @redis
      @end = true
      console.log "【Que】#{@name}: 清空队列并退出！清空了队列中剩余的#{nRemoved}个元素"

  master: (@salves) ->
    @masterServer = new netWork.master @, @salves
    @run()
    @masterServer

  salve: (handler) ->
    @salveServer = netWork.salve handler
    @salveServer


module.exports = Que