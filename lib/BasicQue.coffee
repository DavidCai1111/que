events = require 'events'
co = require 'co'
Task = require './Task'

nextTick = if global.setImmediate == undefined then process.nextTick else global.setImmediate

class BasicQue
  constructor: (@name = '匿名队列') ->
    @queue = []
    @processed = 0
    @rejected = 0
    @end = false
    @emitter = new events.EventEmitter()
    @showLog = false #TODO logger
    @highWaterMark = 1000 #TODO high water mark
    @running = 0
    @limit = 5
    @emitter.on 'push', ((task) ->
      if @end == true
        @end = false
        @run()
    ).bind @

    @on = @emitter.on
    @emit = @emitter.emit

  getNumberOfProcessed: () ->
    @processed

  getNumberOfRejected: () ->
    @rejected

  isEnd: () ->
    @end

  getQueLength: () ->
    Promise.resolve @queue.length

  push: (value) ->
    @queue.push new Task value
    @emitter.emit 'push', value

  shift: () ->
    Promise.resolve @queue.shift()

  processor: (@processor) ->
    unless typeof @processor().then == 'function' then throw new Error "【Que】#{@name}: 处理函数必须返回一个Promise"
    @run()

  run: () ->
    co.call @, () ->
      if @running >= @limit then return nextTick @run.bind @
      if (yield @getQueLength()) == 0 then @end = true
      if @end then return
      task = yield @shift()
      @running += 1
      @process.call @, task
      nextTick @run.bind @

  process: (task) ->
    co.call @, () ->
      result = yield @processor task.data
      @processed += 1
      @running -= 1
      @emit 'done', result, @processed
    .catch ((error) ->
      if task.retryCount > 0
        console.error "【Que】#{@name}: 第#{@processed + 1}个任务出错，错误信息 '#{error.message}' ，开始重试，此任务还剩余的重试次数为#{task.retryCount--}次"
        @process.call @, task
      else
        console.error "【Que】#{@name}: 第#{@processed + 1}个任务出错，错误信息 '#{error.message}' ，错误尝试次数已用尽，放弃此次任务"
        @rejected += 1
        @running -= 1
        @emit 'retryFailed', error, task.data
    ).bind @

  stop: () ->
    @end = true

  restart: () ->
    unless @queue.length == 0 then @end = false

module.exports = BasicQue