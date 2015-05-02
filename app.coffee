http = require 'http'

cfg = require './config'
tools = require './tools'

#TODO add domain
tools.startCluster ->
  app = require './setup/express'

  server = http.Server app

  io = require('./setup/socketio').create server

  server.listen cfg.PORT, cfg.HOST, ->
    console.log "Currency exchange server is runing on
      http://#{cfg.HOST}:#{cfg.PORT}"
