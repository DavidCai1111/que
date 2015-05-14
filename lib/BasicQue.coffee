events = require 'events'
co = require 'co'

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

    @emitter.on 'push', ( () ->
      console.log 'push'
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
    @queue.push value
    @emitter.emit 'push'

  shift: () ->
    Promise.resolve @queue.shift()

  process: (@processor) ->
    if @processor.length != 2
      throw new Error '处理函数的参数数量必须为2'
    @run()

  _done: () ->
    @processed += 1
    @running -= 1
    @.emit 'done', @processed

  run: () ->
    co.call @, () ->
      if @running >= ctx.limit then return nextTick @run.bind @
      if (yield @getQueLength()) == 0 then @end = true
      if @end then return
      task = yield @shift()
      @running += 1
      @processor task, @_done.bind @
      nextTick @run.bind @

  stop: () ->
    @end = true

  restart: () ->
    unless @queue.length == 0 then @end = false

module.exports = BasicQue