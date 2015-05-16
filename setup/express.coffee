express = require 'express'
bodyParser = require 'body-parser'
flash = require 'connect-flash'
ect = require 'ect'
livereload = require 'connect-livereload'

db = require '../db'
cts = require '../controllers'
main = require '../routes'

passport = require './passport'

app = express()

ectEngine = ect
  watch: yes
  root: __dirname + '/../views'
  ext: '.ect'

app.set 'view engine', 'ect'
app.engine 'ect', ectEngine.render

app.use livereload()

app.use cts.domains
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use db.sessions
app.use passport.initialize()
#TODO add logger
app.use passport.session()
app.use flash()
app.get '/confirm/:hash', cts.hash(passport), cts.confirm, cts.enter
app.post '/login', cts.local(passport)
app.use cts.helpers
app.use main

app.use express.static('public')
app.use express.static('bower_components')

app.use cts.notFound
app.use cts.error

module.exports = app
