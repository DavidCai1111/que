events = require 'events'
util = require 'util'
Task = require './Task'
moment = require 'moment'

nextTick = if global.setImmediate == undefined then process.nextTick else global.setImmediate

class Que
  constructor: (@name = 'anonymous queue') ->
    @queue = []
    @processed = 0
    @end = false
    @emitter = new events.EventEmitter()
    @showLog = false #TODO logger

    @emitter.on 'push', ( () ->
      if @end == true
        @end = false
        @run()
    ).bind @

  getNumberOfProcessed: () ->
    @processed

  isEnd: () ->
    @end

  push: (task, processor) ->
    @queue.push new Task task
    @emitter.emit 'push'

  process: (@processor) ->
    if @processor.length != 2
      throw new Error '处理函数的参数数量必须为2'
    @run()

  _done: () ->
    @processed += 1
    console.log "已完成: #{@processed}"
    nextTick @run.bind @

  run: () ->
    if @queue.length == 0 then @end = true
    if @end
      return

    _Task = @queue.shift()
    @processor _Task.data, @_done.bind @
    nextTick @run.bind @
  stop: () ->
    @end = true

  restart: () ->
    @end = false

exports = module.exports = Que