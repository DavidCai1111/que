Que = require '../index'

masterQue = new Que 'test que'

masterQue.master(['http://localhost:8081', 'http://localhost:8082']).listen 8083
masterQue.on 'done', (err, result) ->
  if err then console.error err
  console.log result

handler = (obj) ->
  new Promise (resolve, reject) ->
    count = Math.random()
    if count < 0.4 then reject new Error 'count < 1!'
    resolve obj.data

salveQue1 = new Que 'test que'
salveQue2 = new Que 'test que'
salveQue1.salve(handler).listen 8081
salveQue2.salve(handler).listen 8082
