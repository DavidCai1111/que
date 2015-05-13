events = require 'events'
util = require 'util'
Task = require './Task'

nextTick = if global.setImmediate == undefined then process.nextTick else global.setImmediate

class Que
  constructor: (@name = 'anonymous queue') ->
    @queue = []
    @processed = 0
    @emitter = {}
    @end = false
    @showLog = false #TODO logger
    events.EventEmitter.call @emitter
    util.inherits @emitter, events.EventEmitter

  getNumberOfProcessed: () ->
    @processed

  push: (task, processor) ->
    @queue.push new Task task

  process: (@processor) ->
    if @processor.length != 2
      throw new Error '处理函数的参数数量必须为2'
    @run()

  _done: () ->
    console.log "done #{@processed}"
    @processed += 1
    nextTick @run.bind @

  run: () ->
    if @queue.length == 0
      if @end
        return
      else
        return nextTick @run.bind @

    _Task = @queue.shift()
    @processor _Task.data, @_done.bind @

  exit: () ->
    @end = true


exports = module.exports = Que