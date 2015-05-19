util = require 'util'
request = require 'superagent'

class master
  constructor: (@emitter, @salves) ->
    unless util.isArray @salves then throw new Error "【Que】#{@name}: salves必须为数组"

  distribute: (task) ->
    new Promise ((resolve, reject) ->
      salve = @salves.shift()
      request
      .post salve + '/process'
      .send task
      .set 'Accept', 'application/json'
      .end (err, res) ->
        if err then reject err
        if res.status == 200
          res.text = JSON.parse res.text
          resolve res.text.result
        else
          reject res.text
      @salves.push salve
    ).bind @

module.exports = master