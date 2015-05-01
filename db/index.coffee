redis = require 'redis'
connectRedis = require 'connect-redis'
session = require 'express-session'

RedisStore = connectRedis session

exports.client = redis.createClient()
exports.pub = redis.createClient()
exports.sub = redis.createClient()

exports.sessions = session
  store: new RedisStore
    client: @client
  #TODO move to config
  secret: 'shdfI*^&IU34'


@client.on 'error', (err) ->
  console.error err.stack

exports.users = require './users'

###
users:<id>
users:<id>:bids - set
bids:<id>
bids:<id>:users
asks:<id>
###
