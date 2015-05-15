passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
HashStrategy = require('passport-hash').Strategy
Promise = require 'bluebird'

db = require '../db'

passport.serializeUser (user, done) ->
  return done null, user

passport.deserializeUser (userConfig, done) ->
  user = new db.users userConfig if userConfig
  return done null, user

passport.use new LocalStrategy
  usernameField: 'email'
  passwordField: 'password'
, Promise.coroutine (email, password, done) ->
  user = yield db.users.findByEmail email
  unless user
    return done null, no, message: "Unknown user #{email}"
  unless user.isRegistred()
    return done null, no, message: 'User is unconfirmed'
  unless user.hasPassword password
    return done null, no, message: 'Invalid password'
  return done null, user

passport.use new HashStrategy Promise.coroutine (hash, done) ->
  user = yield db.users.findByHash hash
  unless user
    return done null, no, message: "Can not get user by hash #{hash}"
  unless user.isUnconfirmed()
    return done null, no, message: 'This user is already registred'
  return done null, user

module.exports = passport
