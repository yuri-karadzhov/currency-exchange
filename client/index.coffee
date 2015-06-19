$ ->
  sockets = require './sockets'
  templates = require './templates'

  $('#flashMessages').click -> $(@).slideUp()

  $('#placeBidLink, #placeBidLinkFirst, #placeBidLinkMenu').click ->
    templates.rate.scope.rate = 'Bid'
    templates.rate.render()
    $('#placeRate').modal 'show'

  $('#placeAskLink, #placeAskLinkFirst, #placeAskLinkMenu').click ->
    templates.rate.scope.rate = 'Ask'
    templates.rate.render()
    $('#placeRate').modal 'show'

  $('#bidsTable, #asksTable').click 'tr', ->
    $('#takeRate').modal 'show'

  rateFormValues = ->
    currency: $('#rateCurrencySelector').val()
    left: $('#rateAmountInput').val()
    amount: $('#rateAmountInput').val()
    part: $('#ratePartInput').val()
    time: $('#rateTimePicker').data('DateTimePicker').date().format 'x'
    comment: $('#commentArea').val()

  $('#placeRateButton').click ->
    isBid = templates.rate.scope.rate is 'Bid'
    channel = if isBid then 'bids' else 'asks'
    template = templates[channel]
    rate = rateFormValues()
    template.scope.rates.push rate
    template.render()
    sockets[channel].emit 'place', rate
    $('#placeRate').modal 'hide'
    $('#rateForm').trigger 'reset'
    $('#rateTimePicker').data('DateTimePicker').date moment().add 4, 'hour'

  $('#rateTimePicker').datetimepicker
    format: 'HH:mm'
    stepping: 10
    minDate: moment().add 30, 'minutes'
    maxDate: moment().add 1, 'day'
    defaultDate: moment().add 4, 'hour'
