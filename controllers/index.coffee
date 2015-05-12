db = require '../db'

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

exports.forgotPassword = (req, res, next) ->
  email = req.body.email
  #TODO write flash message
  #TODO check email pattern
  unless email.length
    return res.send 'Enter email'
  return db.users.findByEmail email, (err, user) ->
    return next err if err
    #TODO use flash instead
    return res.send 'User is not registered' unless user
    return user.forgotPassword (err, hash) ->
      return next err if err
      #TODO send email with the link
      return res.send "Restore password:
        <a href='http://localhost:9000/restore/#{hash}'>restore</a>"

exports.restorePage = (req, res, next) ->
  hash = req.params.hash
  return db.users.findByRestore hash, (err, user) ->
    return next err if err
    #TODO use flash instead
    return res.send 'Invalid restore link' unless user
    return res.render 'restore', user: user, hash: hash

exports.restorePassword = (req, res, next) ->
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

  return db.users.findByRestore hash, (err, user) ->
    return next err if err
    #TODO use flash
    return res.send 'Invalid restore link' unless user
    return user.restorePassword {hash, password}, (err) ->
      #TODO use flash
      return next err if err
      return res.redirect '/login'

exports.register = (req, res, next) ->
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

  return db.users.findByEmail email, (err, user) ->
    return next err if err
    #TODO use flash instead
    return res.send 'User already registered' if user
    return db.users.create {
      email
      firstname
      lastname
      room
      password
    }, (err, user) ->
      return next err if err
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

exports.confirm = (req, res, next) ->
  userId = req.user.id
  return db.users.findById userId, (err, user) ->
    #TODO use flash instead
    return res.send err.stack if err
    return res.send new Error 'User not found' unless user
    return user.persist next

exports.enter = (req, res) ->
  return res.redirect '/'

exports.notFound = (req, res) ->
  return res.status 404
  .render 'notfound'

exports.error = (err, req, res, next) ->
  console.error err.stack
  return res.status 500
  .render 'error', error: err.stack
