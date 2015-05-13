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
    @_run()

  _run: () ->
    if @queue.length == 0
      if @end
        return
      else
        return nextTick @_run.bind @

    _Task = @queue.pop()
    @processor _Task.data
    @processed += 1
    nextTick @_run.bind @

  exit: () ->
    @end = true

exports = module.exports = Que