passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
HashStrategy = require('passport-hash').Strategy

db = require '../db'

passport.serializeUser (user, done) ->
  return done null, user

passport.deserializeUser (user, done) ->
  return done null, user

passport.use new LocalStrategy
  usernameField: 'email'
  passwordField: 'password'
, (email, password, done) ->
  return db.users.findByEmail email, (err, user) ->
    return done err if err
    unless user
      return done null, no, message: "Unknown user #{email}"
    unless user.isRegistred()
      return done null, no, message: 'User is unconfirmed'
    unless user.hasPassword password
      return done null, no, message: 'Invalid password'
    return done null, user

passport.use new HashStrategy (hash, done) ->
  return db.users.findByHash hash, (err, user) ->
    return done err if err
    unless user
      return done null, no, message: "Can not get user by hash #{hash}"
    unless user.isUnconfirmed()
      return done null, no, message: 'This user is already registred'
    return done null, user

module.exports = passport
