$ ->
  console.log 'hi world!'
  $('#placeBidLink').click -> $('#placeBid').modal 'show'
  $('#bidTimePicker').datetimepicker
    format: 'HH:mm'
    stepping: 10
    minDate: moment().add 30, 'minutes'
    maxDate: moment().add 1, 'day'
    defaultDate: moment().add 4, 'hour'
    
