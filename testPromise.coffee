co = require 'co'

pro = () ->
  new Promise (resolve) ->
    a = 2
    resolve 2

co () ->
  console.log yield pro()
  console.log 'ok'