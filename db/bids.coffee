Promise = require 'bluebird'

db = require './'
tools = require '../tools'

client = db.client

class Bid
  #TODO connect with asks
  constructor: ({
    @id
    @uid
    @currency
    @amount
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
    part
    time
    comment
  }) ->
    bidId = yield client.incr 'bids:next'
    #TODO check if it is valid
    bidConfig =
      id: bidId + ''
      uid: userId
      currency: currency
      amount: amount
      part: part
      time: time
      comment: comment
      status: 'open'
    client.sadd "users:#{userId}:bids", bidId
    client.hmset "bids:#{bidId}", bidConfig
    return new Bid bidConfig

  @findById: Promise.coroutine (bidId) ->
    bidConfig = yield client.hgetall "bids:#{bidId}"
    return new Bid bidConfig

module.exports = Bid
