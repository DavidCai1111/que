should = require 'should'
EventProxy = require 'eventproxy'
Que = require '../index'

describe 'test singleton mode', () ->
  it 'should done all tasks', (done) ->
    que = new Que 'test que'
    ep = new EventProxy()
    ep.after 'done', 10 , () ->
      processed = que.getNumberOfProcessed()
      rejected = que.getNumberOfRejected()
      (processed + rejected).should.be.equal 10
      que.stop()
      done()

    handler = (obj) ->
      new Promise (resolve, reject) ->
        count = Math.random()
        if count < 0.4 then reject new Error 'count < 1!'
        resolve obj.data

    que.on 'done', (err, result) ->
      if err then console.error err
      ep.emit 'done'

    que.processor handler

    que.push {data: 'data'} for i in [0..10]
