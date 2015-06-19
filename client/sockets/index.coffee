Bids = require './bids'
Asks = require './asks'

exports.bids = new Bids().channel
exports.asks = new Asks().channel
