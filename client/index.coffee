$ ->
  console.log 'hi world!'
  $('#placeBidLink').click -> $('#placeBid').modal 'show'
  $('#bidTimePicker').datetimepicker format: 'LT'
