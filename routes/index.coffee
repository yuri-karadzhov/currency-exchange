express = require 'express'
router = express.Router()

cts = require '../controllers'

router.get '/', cts.isAuth, cts.main

router.get '/login', cts.login

router.get '/logout', cts.isAuth, cts.logout

router.post '/register', cts.register

module.exports = router
