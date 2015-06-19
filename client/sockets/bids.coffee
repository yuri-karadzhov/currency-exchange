Channel = require './channel'
templates = require '../templates'

class Bids extends Channel
  
  constructor: ->
    super 'bids'
    
    @channel.emit 'list'
      
    @channel.on 'list', (bids) ->
      templates.bids.scope.rates = bids
      templates.bids.render()
  
    @channel.on 'place', (bid) ->
      console.log 'place', bid

module.exports = Bids
      