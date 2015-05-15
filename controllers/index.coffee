domain = require 'domain'
Promise = require 'bluebird'

db = require '../db'

exports.domains = (req, res, next) ->
  requestDomain = domain.create()
  requestDomain.add req
  requestDomain.add res
  requestDomain.on 'error', (err) ->
    #FIXME do not handle Promise.coroutine exceptions
    console.log 'domain error:', err
    next err
  requestDomain.run next

exports.helpers = (req, res, next) ->
  res.locals.helpers = user: req.user
  return next()

exports.main = (req, res, next) ->
  return res.render 'index'

exports.login = (req, res, next) ->
  return res.render 'login'

exports.logout = (req, res, next) ->
  req.logOut()
  return res.redirect '/login'

exports.isAuth = (req, res, next) ->
  return next() if req.isAuthenticated()
  if req.method is 'GET'
    return res.redirect '/login'
  return res.json
    success: no
    message: 'Not authenticated'

exports.forgotPassword = Promise.coroutine (req, res, next) ->
  email = req.body.email
  #TODO write flash message
  #TODO check email pattern
  unless email.length
    return res.send 'Enter email'
  user = yield db.users.findByEmail email
  #TODO use flash instead
  return res.send 'User is not registered' unless user
  hash = yield user.forgotPassword()
  #TODO send email with the link
  return res.send "Restore password:
      <a href='http://localhost:9000/restore/#{hash}'>restore</a>"

exports.restorePage = Promise.coroutine (req, res, next) ->
  hash = req.params.hash
  user = yield db.users.findByRestore hash
  #TODO use flash instead
  return res.send 'Invalid restore link' unless user
  return res.render 'restore', user: user, hash: hash

exports.restorePassword = Promise.coroutine (req, res, next) ->
  data = req.body
  hash = data.hash
  password = data.password
  confirmpassword = data.confirmpassword

  #TODO use flash
  #TODO check password strenth
  unless password.length
    return res.send 'Enter password'
  unless password is confirmpassword
    return res.send 'Password did not match confirmation'

  user = yield db.users.findByRestore hash
  #TODO use flash
  return res.send 'Invalid restore link' unless user
  yield user.restorePassword {hash, password}
  #TODO use flash
  return res.redirect '/login'

exports.register = Promise.coroutine (req, res, next) ->
  data = req.body
  email = data.email
  firstname = data.firstname
  lastname = data.lastname
  room = data.room
  password = data.password
  confirmpassword = data.confirmpassword

  #TODO write flash messages instead
  #TODO check email pattern and password strength
  unless email.length
    return res.send 'Enter email'
  unless firstname.length
    return res.send 'Enter first name'
  unless lastname.length
    return res.send 'Enter last name'
  unless room.length
    return res.send 'Enter room number'
  unless password.length
    return res.send 'Enter password'
  unless password is confirmpassword
    return res.send 'Password did not match confirmation'

  user = yield db.users.findByEmail email
  #TODO use flash instead
  return res.send 'User already registered' if user
  user = yield db.users.create {
    email
    firstname
    lastname
    room
    password
  }
  #TODO use email confirmation
  return res.send "Confirm registration
    <a href='http://localhost:9000/confirm/#{user.hash}'>confirm</a>"

exports.hash = (passport) ->
  #TODO add flash message
  return passport.authenticate 'hash',
    failureRedirect: '/login'

exports.local = (passport) ->
  #TODO add flash message
  return passport.authenticate 'local',
    successRedirect: '/',
    failureRedirect: '/login'

exports.confirm = Promise.coroutine (req, res, next) ->
  userId = req.user.id
  user = yield db.users.findById userId
  #TODO use flash instead
  return res.send new Error 'User not found' unless user
  yield user.persist()
  return next()

exports.enter = (req, res) ->
  return res.redirect '/'

exports.notFound = (req, res) ->
  return res.status 404
  .render 'notfound'

exports.error = (err, req, res, next) ->
  console.error err.stack
  return res.status 500
  .render 'error', error: err.stack
