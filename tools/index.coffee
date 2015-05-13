crypto = require 'crypto'
cluster = require 'cluster'
os = require 'os'

cfg = require '../config'

exports.isDevelopment = ->
  return cfg.ENVIRONMENT is 'development'

exports.hash = (val, sole = cfg.SOLE) ->
  hash = crypto.createHash 'md5'
  hash.update sole + val, 'ascii'
  return hash.digest 'hex'

exports.print = -> console.log arguments...

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

exports.startCluster = (start) ->
  cpus = if @isDevelopment() then 1 else os.cpus().length
  gc = global.gc
  if cluster.isMaster
    cluster.fork() while cpus--
    cluster.on 'exit', (worker, code, signal) ->
      clearInterval gcInterval if gc
      console.log "Worker #{worker.id} died: #{worker.process.pid}"
  else
    gcInterval = setInterval gc, cfg.GC_INTERVAL if gc
    worker = cluster.worker
    console.log "Worker #{worker.id} started: #{worker.process.pid}"
    start()
