class Channel

  copts:
    'connect timeout': 5000
    'max reconnection attempts': 4

  registred: 0

  showConnect: ->
    console.log 'connecting...'

  hideConnect: ->
    console.log 'connected'

  showError: ->
    @showConnect()
    $('#connect_error').show()

  constructor: (@name) ->
    #FIXME remove localhost:9000 or take it from URL
    @channel = io "localhost:9000/#{@name}", @copts

    @channel.on 'connecting', =>
      @registred++
      #TODO check if this fix still required
      @channel.attempts = 0
      @reload = setTimeout =>
        @showError()
        setTimeout ->
          window.location.reload()
        , 5000
      , 25000

    @channel.on 'connect', =>
      clearTimeout @reload
      @registred--
      @hideConnect() unless @registred

    @channel.on 'connect_failed', =>
      console.log 'connect_failed'
      @showError()

    @channel.on 'reconnecting', =>
      @channel.attempts++
      @showError() if @channel.attempts is @copts['max reconnection attempts']

    @channel.on 'reconnect', =>
      @channel.attempts--
      window.location.reload()
      #TODO pull new data from server and update views instead of reloading

    @channel.on 'reconnect_failed', =>
      console.log 'reconnect_failed'
      @showError()

    @channel.on 'disconnect', =>
      @registred++
      @showConnect()

    @channel.on 'error', =>
      @showError()

module.exports = Channel
