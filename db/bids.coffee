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

  @create: (userId, {
    currency
    amount
    part
    time
    comment
  }, cb) ->
    return client.incr 'bids:next', (err, bidId) ->
      return cb err, null if err
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
      bid = new Bid bidConfig
      return cb null, bid

  @findById: (bidId, cb) ->
    return client.hgetall "bids:#{bidId}", (err, bidConfig) ->
      return cb err, null if err or not bidConfig
      bid = new Bid bidConfig
      return cb null, bid

module.exports = Bid
