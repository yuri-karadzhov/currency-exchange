passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
HashStrategy = require('passport-hash').Strategy

tools = require '../tools'
db = require '../db'

passport.serializeUser (user, done) ->
  return done null, user

passport.deserializeUser (userConfig, done) ->
  user = new db.users userConfig if userConfig
  return done null, user

passport.use new LocalStrategy
  usernameField: 'email'
  passwordField: 'password'
, tools.wrap (email, password, done) ->
  console.log 'passport', email
  user = yield db.users.findByEmail email
  console.log 'passport', user
  unless user
    return done null, no, message: "Unknown user #{email}"
  unless user.isRegistred()
    return done null, no, message: 'User is unconfirmed'
  unless user.hasPassword password
    return done null, no, message: 'Invalid password'
  return done null, user

passport.use new HashStrategy tools.wrap (hash, done) ->
  console.log hash
  user = yield db.users.findByHash hash
  console.log user
  unless user
    return done null, no, message: "Can not get user by hash #{hash}"
  unless user.isUnconfirmed()
    return done null, no, message: 'This user is already registred'
  return done null, user

module.exports = passport
