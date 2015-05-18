Que = require './index'

queue = new Que 'myTaskQue'
queue.master ['http://localhost:8080', 'http://localhost:8081']

queue.on 'done', () ->
  console.log 'done!'

handler = (obj) ->
  new Promise (resolve, reject) ->
    count = Math.random()
    #    if count < 0.1 then reject new Error 'count < 1!'
    console.log "fuck the #{obj.data}"
    resolve obj.data

queue2 = new Que('myTaskQue')
queue2.salve(handler).listen 8080
console.log 'listened at port 8080'

queue3 = new Que('myTaskQue')
queue3.salve(handler).listen 8081
console.log 'listened at port 8081'

otherTask = () ->
  queue.push {data: 'fuck'}

getProcessed = () ->
  console.log "共完成了：#{queue.getNumberOfProcessed()} 个任务"

exit = () ->
  queue.stop()

queue.push {data: 'haha'}
queue.push {data: 'shit'}
queue.push {data: 'shit'}
queue.push {data: 'shit'}
queue.push {data: 'shit'}
queue.push {data: 'shit'}
queue.push {data: 'shit'}
queue.push {data: 'haha'}

setTimeout otherTask, 1000 * 2
setTimeout otherTask, 1000 * 4
setTimeout otherTask, 1000 * 6
setTimeout getProcessed, 1000 * 9
setTimeout exit, 1000 * 10