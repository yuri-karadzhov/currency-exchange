sio = require 'socket.io'
redisAdapter = require 'socket.io-redis'
Promise = require 'bluebird'

passport = require './passport'
tools = require '../tools'
db = require '../db'

exports.create = (server) ->

  io = sio server

  io.adapter redisAdapter()


  io.use tools.expressToSocket db.sessions
  io.use tools.expressToSocket passport.initialize()
  io.use tools.expressToSocket passport.session()

  #TODO move out routes to separate files
  bids = io.of '/bids'
  bids.on 'connection', (socket) ->

    user = socket.request.user
    return unless user
    
    socket.on 'list', Promise.coroutine ->
      socket.emit 'list', yield user.getBids()

    socket.on 'place', (bid) ->
      console.log 'place', bid
      user.placeBid bid

  asks = io.of '/asks'
  asks.on 'connection', (socket) ->

    user = socket.request.user
    return unless user

    socket.on 'list', Promise.coroutine ->
      console.log yield user.getAsks()
      socket.emit 'list', yield user.getAsks()

    socket.on 'place', (ask) ->
      console.log 'place ask', ask
      user.placeAsk ask

  return io
