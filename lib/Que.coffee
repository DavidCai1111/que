events = require 'events'
util = require 'util'
Task = require './Task'

nextTick = if global.setImmediate == undefined then process.nextTick else global.setImmediate

class Que
  constructor: () ->
    @queue = []
    @processed = 0
    @emitter = {}
    @isRunning = false
    events.EventEmitter.call @emitter
    util.inherits @emitter, events.EventEmitter
    @_run()

  getNumberOfProcessed: () ->
    @processed

  push: (task, processor) ->
    @queue.push new Task task, processor

  _run: () ->
    @isRunning = true
    if @queue.length == 0
      @isRunning = false
      nextTick @_run.bind @
      return

    _Task = @queue.pop()
    _Task.processor _Task.data
    @processed += 1
    nextTick @_run.bind @

exports = module.exports = Que