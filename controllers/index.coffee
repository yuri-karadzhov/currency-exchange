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
  return res.render 'login',
    errors: req.flash 'error'
    infos: req.flash 'info'

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
  #TODO check email pattern
  unless email.length
    req.flash 'error', 'Email not specified'
    return res.redirect '/login'
  user = yield db.users.findByEmail email
  unless user
    req.flash 'error', 'User is not registered'
    return res.redirect '/login'
  hash = yield user.forgotPassword()
  yield user.persist()
  #TODO send email with the link
  return res.send "Restore password:
      <a href='http://localhost:9000/restore/#{hash}'>restore</a>"

exports.restorePage = Promise.coroutine (req, res, next) ->
  hash = req.params.hash
  user = yield db.users.findByRestore hash
  unless user
    req.flash 'error', 'Invalid restore link'
    return res.redirect '/login'
  return res.render 'restore', user: user, hash: hash

exports.restorePassword = Promise.coroutine (req, res, next) ->
  data = req.body
  hash = data.hash
  password = data.password
  confirmpassword = data.confirmpassword

  #TODO check password strenth
  unless password.length
    req.flash 'error', 'Enter password'
    return res.redirect '/login'
  unless password is confirmpassword
    req.flash 'error', 'Password did not match confirmation'
    return res.redirect '/login'

  user = yield db.users.findByRestore hash
  unless user
    req.flash 'error', 'Invalid restore link'
    return res.redirect '/login'
  yield user.restorePassword {hash, password}
  req.flash 'info', 'Your password is reset, please log in'
  return res.redirect '/login'

exports.register = Promise.coroutine (req, res, next) ->
  data = req.body
  email = data.email
  firstname = data.firstname
  lastname = data.lastname
  room = data.room
  password = data.password
  confirmpassword = data.confirmpassword

  #TODO check email pattern and password strength
  errors = no
  unless email.length
    errors = yes
    req.flash 'error', 'Enter email'
  unless firstname.length
    errors = yes
    req.flash 'error', 'Enter first name'
  unless lastname.length
    errors = yes
    req.flash 'error', 'Enter last name'
  unless room.length
    errors = yes
    req.flash 'error', 'Enter room number'
  unless password.length
    errors = yes
    req.flash 'error', 'Enter password'
  unless password is confirmpassword
    errors = yes
    req.flash 'error', 'Password did not match confirmation'
  return res.redirect '/login' if errors

  user = yield db.users.findByEmail email
  if user
    req.flash 'User already registered'
    return res.redirect '/login'
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
  return passport.authenticate 'hash',
    failureRedirect: '/login'
    failureFlash: yes

exports.local = (passport) ->
  return passport.authenticate 'local',
    successRedirect: '/'
    failureRedirect: '/login'
    failureFlash: yes

exports.confirm = Promise.coroutine (req, res, next) ->
  userId = req.user.id
  user = yield db.users.findById userId
  unless user
    req.flash 'error', 'User not found'
    return res.reirect '/login'
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
