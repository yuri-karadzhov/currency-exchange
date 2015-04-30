http = require 'http'

app = require './setup/express'

server = http.Server app

io = require('./setup/socketio').create server

server.listen 9000, -> console.log "Currency exchange server
  is runing on http://#{server.address().address}:#{server.address().port}"
