crypto = require 'crypto'

#TODO move to config
sole = "sjkTU^U23"

exports.hash = (val) ->
  hash = crypto.createHash 'md5'
  hash.update Date() + val, 'ascii'
  return hash.digest 'hex'

exports.sole = (val) ->
  hash = crypto.createHash 'md5'
  hash.update sole + val, 'ascii'
  return hash.digest 'hex'

exports.expressToSocket = (middle) ->
  return (socket, next) ->
    return middle socket.request, socket.request.res, next

#TODO Check and complete this function
exports.socketToExpress = (middle) ->
  return (req, res, next) ->
    request = req
    request.res = res
    socket = request: request
    return middle socket, next
