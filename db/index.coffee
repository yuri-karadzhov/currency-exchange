redis = require 'then-redis'
connectRedis = require 'connect-redis'
session = require 'express-session'

cfg = require '../config'

RedisStore = connectRedis session

exports.client = redis.createClient()

exports.sessions = session
  store: new RedisStore
    client: @client._redisClient
  secret: cfg.SECRET


@client.on 'error', (err) ->
  console.error err.stack

exports.users = require './users'
exports.bids = require './bids'
exports.asks = require './asks'

###
users:<id>
users:<id>:bids - set
bids:<id>
bids:<id>:users
asks:<id>
###
