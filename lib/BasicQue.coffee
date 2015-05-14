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
      if @end == true
        @end = false
        @run()
    ).bind @

    @.on = @emitter.on
    @.emit = @emitter.emit

  getNumberOfProcessed: () ->
    @processed

  isEnd: () ->
    @end

  getQueLength: () ->
    ctx = @
    new Promise (resolve) ->
      resolve ctx.queue.length

  push: (value) ->
    ctx = @
    co () ->
      yield new Promise (resolve) ->
        ctx.queue.push value
        ctx.emitter.emit 'push'
        resolve value

  shift: () ->
    ctx = @
    new Promise (resolve) ->
      resolve ctx.queue.shift()

  process: (@processor) ->
    if @processor.length != 2
      throw new Error '处理函数的参数数量必须为2'
    @run()

  _done: () ->
    @processed += 1
    @running -= 1
    @.emit 'done', @processed

  run: () ->
    ctx = @
    co () ->
      if ctx.running >= ctx.limit then return nextTick ctx.run.bind ctx
      if (yield ctx.getQueLength()) == 0 then ctx.end = true
      if ctx.end then return
      task = yield ctx.shift()
      console.dir task
      ctx.running += 1
      ctx.processor task, ctx._done.bind ctx
      nextTick ctx.run.bind ctx

  stop: () ->
    @end = true

  restart: () ->
    unless @queue.length == 0 then @end = false

module.exports = BasicQue