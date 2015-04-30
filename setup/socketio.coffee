sio = require 'socket.io'
session = require 'express-session'

tools = require '../tools'
db = require '../db'

exports.create = (server) ->

  io = sio server

  io.use tools.expressToSocket db.sessions
  
  return io
