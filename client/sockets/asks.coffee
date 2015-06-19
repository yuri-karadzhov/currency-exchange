Channel = require './channel'
templates = require '../templates'

class Asks extends Channel

  constructor: ->
    super 'asks'

    @channel.emit 'list'

    @channel.on 'list', (asks) ->
      console.log asks
      templates.asks.scope.rates = asks
      templates.asks.render()

    @channel.on 'place', (ask) ->
      console.log 'place', ask

module.exports = Asks
