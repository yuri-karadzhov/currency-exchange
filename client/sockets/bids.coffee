Channel = require './channel'

class Bids extends Channel
  
  constructor: ->
    super 'bids'
  
    @channel.on 'place', (bid) ->
      console.log 'place', bid

module.exports = Bids
      