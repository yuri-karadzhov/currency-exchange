Promise = require 'bluebird'

db = require './'
tools = require '../tools'

client = db.client

class Ask
  #TODO connect with bids
  constructor: ({
  @id
  @uid
  @currency
  @amount
  @left
  @part
  @time
  @comment
  @status
  }) ->

  isValid: ->

  isOpen: -> @status is 'open'

  @create: Promise.coroutine (userId, {
  currency
  amount
  left
  part
  time
  comment
  }) ->
    askId = yield client.incr 'asks:next'
    #TODO check if it is valid
    askConfig =
      id: askId + ''
      uid: userId
      currency: currency
      amount: amount
      left: left
      part: part
      time: time
      comment: comment
      status: 'open'
    client.sadd "users:#{userId}:asks", askId
    client.hmset "asks:#{askId}", askConfig
    return new Ask askConfig

  @findById: Promise.coroutine (askId) ->
    askConfig = yield client.hgetall "asks:#{askId}"
    return new Ask askConfig

module.exports = Ask
