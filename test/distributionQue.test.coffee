should = require 'should'
EventProxy = require 'eventproxy'
Que = require '../index'

describe 'test distribution mode', () ->
  it 'should done all tasks', (done) ->
    masterQue = new Que 'test que'
    ep = new EventProxy()

    ep.after 'done', 10 , () ->
      processed = masterQue.getNumberOfProcessed()
      rejected = masterQue.getNumberOfRejected()
      console.log "processed : #{processed}"
      console.log "rejected : #{rejected}"
      (processed + rejected).should.be.equal 10
      masterQue.stop()
      done()

    masterQue.master ['http://localhost:8081','http://localhost:8082']
    masterQue.on 'done', (err, result) ->
      if err then console.error err
      ep.emit 'done'

    handler = (obj) ->
      new Promise (resolve, reject) ->
        count = Math.random()
        if count < 0.4 then reject new Error 'count < 1!'
        resolve obj.data

    salveQue1 = new Que 'test que'
    salveQue2 = new Que 'test que'
    salveQue1.salve(handler).listen 8081
    salveQue2.salve(handler).listen 8082

    for i in [0..10]
      masterQue.push {data: 'data'}