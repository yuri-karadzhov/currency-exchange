template = soma.template.create $('#bidPanel').get(0)

template.scope.timeFormat = (time) -> moment.unix(time).format 'HH:mm'
template.scope.rates = []
template.render()

module.exports = template
