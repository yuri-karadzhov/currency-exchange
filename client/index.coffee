$ ->
  bidsTemplate = soma.template.create $('#bidPanel').get(0)
  asksTemplate = soma.template.create $('#askPanel').get(0)
  rateTemplate = soma.template.create $('#placeRate').get(0)

  bidsTemplate.scope.bids = []
  bidsTemplate.render()

  asksTemplate.scope.asks = []
  asksTemplate.render()

  $('#placeBidLink').click ->
    rateTemplate.scope.rate = 'Bid'
    rateTemplate.render()
    $('#placeRate').modal 'show'

  $('#placeAskLink').click ->
    rateTemplate.scope.rate = 'Ask'
    rateTemplate.render()
    $('#placeRate').modal 'show'

  rateFormValues = ->
    currency: $('#rateCurrencySelector').val()
    left: $('#rateAmountInput').val()
    amount: $('#rateAmountInput').val()
    part: $('#ratePartInput').val()
    time: $('#rateTimePickerInput').val()

  $('#placeRateButton').click ->
    rate = rateTemplate.scope.rate
    if rate is 'Bid'
      bidsTemplate.scope.bids.push rateFormValues()
      $('#placeRate').modal 'hide'
      bidsTemplate.render()
    else
      asksTemplate.scope.asks.push rateFormValues()
      $('#placeRate').modal 'hide'
      asksTemplate.render()

  $('#rateTimePicker').datetimepicker
    format: 'HH:mm'
    stepping: 10
    minDate: moment().add 30, 'minutes'
    maxDate: moment().add 1, 'day'
    defaultDate: moment().add 4, 'hour'
