express = require 'express'
router = express.Router()

cts = require '../controllers'

router.get '/', cts.isAuth, cts.main

router.get '/login', cts.login

router.get '/logout', cts.isAuth, cts.logout

router.post '/forgot', cts.forgotPassword

router.get '/restore/:hash', cts.restorePage

router.post '/restore', cts.restorePassword

router.post '/register', cts.register

module.exports = router
