redis = require 'redis'

exports.createClient = () ->
  client = redis.createClient arguments

  client.on 'error', (err) ->
    console.error "redis error: #{error}"

  client

exports.releaseClient = (client) ->
  client.quit()