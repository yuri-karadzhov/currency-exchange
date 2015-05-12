$ ->
  sockets = require './sockets'
  
  bidsTemplate = soma.template.create $('#bidPanel').get(0)
  asksTemplate = soma.template.create $('#askPanel').get(0)
  rateTemplate = soma.template.create $('#placeRate').get(0)

  bidsTemplate.scope.timeFormat = (time) -> time.format 'HH:mm'
  bidsTemplate.scope.rates = []
  bidsTemplate.render()

  asksTemplate.scope.timeFormat = (time) -> time.format 'HH:mm'
  asksTemplate.scope.rates = []
  asksTemplate.render()

  $('#placeBidLink, #placeBidLinkFirst, #placeBidLinkMenu').click ->
    rateTemplate.scope.rate = 'Bid'
    rateTemplate.render()
    $('#placeRate').modal 'show'

  $('#placeAskLink, #placeAskLinkFirst, #placeAskLinkMenu').click ->
    rateTemplate.scope.rate = 'Ask'
    rateTemplate.render()
    $('#placeRate').modal 'show'

  rateFormValues = ->
    currency: $('#rateCurrencySelector').val()
    left: $('#rateAmountInput').val()
    amount: $('#rateAmountInput').val()
    part: $('#ratePartInput').val()
    time: $('#rateTimePicker').data('DateTimePicker').date()
    comment: $('#commentArea').val()

  $('#placeRateButton').click ->
    isBid = rateTemplate.scope.rate is 'Bid'
    template = if isBid then bidsTemplate else asksTemplate
    rate = rateFormValues()
    template.scope.rates.push rate
    template.render()
    channel = if isBid then 'bids' else 'asks'
    sockets[channel].emit 'place', rate
    console.log rate
    $('#placeRate').modal 'hide'
    $('#rateForm').trigger 'reset'
    $('#rateTimePicker').data('DateTimePicker').date moment().add 4, 'hour'

  $('#rateTimePicker').datetimepicker
    format: 'HH:mm'
    stepping: 10
    minDate: moment().add 30, 'minutes'
    maxDate: moment().add 1, 'day'
    defaultDate: moment().add 4, 'hour'
