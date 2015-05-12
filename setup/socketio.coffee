sio = require 'socket.io'
session = require 'express-session'
redisAdapter = require 'socket.io-redis'

tools = require '../tools'
db = require '../db'

exports.create = (server) ->

  io = sio server
  
  io.adapter redisAdapter()

  io.use tools.expressToSocket db.sessions
  
  #TODO move out routes to separate files
  bids = io.of '/bids'
  bids.on 'connection', (socket) ->
    
    console.log socket
  
    socket.on 'place', (bid) ->
      console.log 'place', bid
  
  return io
