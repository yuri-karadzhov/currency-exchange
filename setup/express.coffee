express = require 'express'
bodyParser = require 'body-parser'
ect = require 'ect'
livereload = require 'connect-livereload'

db = require '../db'
cts = require '../controllers'
main = require '../routes'

passport = require './passport'

app = express()

ectRenderer = ect
  watch: yes
  root: __dirname + '/../views'
  ext: '.ect'

app.set 'view engine', 'ect'
app.engine 'ect', ectRenderer.render

app.use livereload()

app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use db.sessions
app.use passport.initialize()
#TODO add session secrete and move it to config
#TODO add logger
app.use passport.session()
app.get '/confirm/:hash', cts.hash(passport), cts.confirm, cts.enter
app.post '/login', cts.local(passport)
app.use cts.helpers
app.use main

app.use express.static('public')
app.use express.static('bower_components')

app.use cts.notFound
app.use cts.error

module.exports = app
