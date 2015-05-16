events = require 'events'
co = require 'co'
Task = require './Task'

nextTick = if global.setImmediate == undefined then process.nextTick else global.setImmediate

class BasicQue
  constructor: (@name = 'anonymous queue') ->
    @queue = []
    @processed = 0
    @end = false
    @emitter = new events.EventEmitter()
    @showLog = false #TODO logger
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

  isEnd: () ->
    @end

  getQueLength: () ->
    Promise.resolve @queue.length

  push: (value) ->
    @queue.push new Task value
    @emitter.emit 'push', value

  shift: () ->
    Promise.resolve @queue.shift()

  process: (@processor) ->
    unless typeof @processor().then == 'function' then throw new Error '处理函数必须返回一个Promise'
    @run()

  run: () ->
    co.call @, () ->
      if @running >= @limit then return nextTick @run.bind @
      if (yield @getQueLength()) == 0 then @end = true
      if @end then return
      task = yield @shift()
      @running += 1
      result = yield @processor task.data
      @processed += 1
      @running -= 1
      @emit 'done', result, @processed
      nextTick @run.bind @

  stop: () ->
    @end = true

  restart: () ->
    unless @queue.length == 0 then @end = false

module.exports = BasicQue