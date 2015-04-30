db = require '../db'

exports.helpers = (req, res, next) ->
  res.locals.helpers = user: req.user
  next()

exports.main = (req, res, next) ->
  res.render 'index'

exports.login = (req, res, next) ->
  return res.render 'login'

exports.logout = (req, res, next) ->
  req.logOut()
  res.redirect '/login'

exports.isAuth = (req, res, next) ->
  return next() if req.isAuthenticated()
  if req.method is 'GET'
    return res.redirect '/login'
  return res.json
    success: no
    message: 'Not authenticated'

exports.register = (req, res, next) ->
  data = req.body
  email = data.email
  firstname = data.firstname
  lastname = data.lastname
  room = data.room
  password = data.password
  confirmpassword = data.confirmpassword
  
  unless email.length
    return res.send 'Enter email'
  unless firstname.length
    return res.send 'Enter first name'
  unless lastname.length
    return res.send 'Enter last name'
  unless room.length
    return 'Enter room number'
  unless password.length
    return res.send 'Enter password'
  unless password is confirmpassword
    return res.send 'Password did not match confirmation'

  db.users.findByEmail email, (err, user) ->
    return next err if err
    return res.send 'User already registered' if user
    return db.users.create {
      email
      firstname
      lastname
      room
      password
    }, (err, user) ->
      return next err if err
      return res.send """
        Confirm registration
        <a href='http://localhost:9000/confirm/#{user.hash}'>confirm</a>
        """
  
exports.hash = (passport) ->
  return passport.authenticate 'hash',
    failureRedirect: '/login'

exports.local = (passport) ->
  passport.authenticate 'local',
    successRedirect: '/',
    failureRedirect: '/login'
  
exports.confirm = (req, res, next) ->
  uid = req.user.id
  return db.users.findById uid, (err, user) ->
    return res.send err.stack if err or not user
    return user.persist next

exports.enter = (req, res, next) ->
  return res.redirect '/'

exports.notFound = (req, res) ->
  res.status 404
  .render 'notfound'

exports.error = (err, req, res, next) ->
  console.error err.stack
  res.status 500
  .render 'error', error: err.stack
