express = require "express"
compression = require "compression"
pug = require "pug"
cookieParser = require "cookie-parser"
bodyParser = require "body-parser"
fs = require "fs"
path = require "path"

Pages = require "../pages"
logger = require "../logger"

__root = path.dirname require.main.filename
__rootRelative = path.relative __dirname, __root

__options = 
	port: 8080
	views: "./views"
	cookieSecret: "__cookieSecret__"
	static: "./public"
	pages: "./pages"
	name: "Diving Squirrel"
	baseURL: ""
	styles: []
	scripts: []
	production: no
	onLoggedUser: (user, next) ->
		next no, {}

__instance = null
__registered = no
__info = 
	warn: 0
	error: 0

__warn = (message) ->
	logger.warn message
	__info.warn++

__error = (message) ->
	logger.error message
	__info.error++

__createExpressApp = (instance) ->
	app = express()

	app.set "views", instance.options.views
	app.set "view engine", "pug"
	app.use cookieParser instance.options.cookieSecret
	app.use express.static instance.options.static
	app.use compression()
	app.use bodyParser.urlencoded extended: no
	app.use bodyParser.json()

	app.use (req, res, next) ->
		res.loginUser = (u) ->
			res.cookie "u", u, signed: yes
		res.logoutUser = ->
			res.clearCookie "u"
		res.send404 = (message = "Page not found") ->
			res.status 404
			next message
		res.send401 = (message = "Unauthorized request") ->
			res.status 401
			next message
		next()

	app.use (req, res, next) ->
		return next() unless req.signedCookies.u
		instance.options.onLoggedUser? req.signedCookies.u, (err, user) ->
			return next err if err
			req.user = user
			next()

	instance.app = app

	Pages.register instance.options.pages, instance, (err, pages) ->
		__registered = yes
		return __error err if err
		logger.log "Pages registered"
		for page in pages
			dir = page.constructor.name.toLowerCase()
			__warn "Directory '#{dir}' not found in #{instance.options.views}." unless fs.existsSync "#{instance.options.views}/#{dir}"

module.exports = class App
	constructor: (options = {}) ->
		return __error "App already instantiated" unless __instance is null
		__instance = @
		@server = null
		App.instance = __instance
		@options = {}
		@options[k] = v for k, v of __options
		@options[k] = v for k, v of options
		__warn "CookieSecret is default. You should change it." if @options.cookieSecret is __options.cookieSecret
		__warn "File 'layout.pug' not found in #{@options.views}. Layout of the route will be rendered in HTMLResponse." unless fs.existsSync "#{@options.views}/layout.pug"
		__createExpressApp @

		@name = @options.name
		@started = no


		App.config = __instance.options

	use: (route, callback) ->
		return @app.use route unless callback
		@app.use route, callback
	get: (route, callback) ->
		@app.get route, callback
	post: (route, callback) ->
		@app.post route, callback
	put: (route, callback) ->
		@app.put route, callback
	head: (route, callback) ->
		@app.head route, callback
	delete: (route, callback) ->
		@app.delete route, callback
	start: (cb) ->
		return __error "Application already started" if @started
		@started = yes
		interval = setInterval =>
			return unless __registered
			clearInterval interval
			@app.use "*", (req, res, next) ->
				res.send404()
			@app.use (err, req, res, next) =>
				res.status 500 if res.statusCode is 200
				if err instanceof Error
					err = "#{err.message}\n#{err.stack}"
				body = "#{JSON.stringify req.body} "
				body = "" if req.method in ["GET", "HEAD"]
				logger.error "#{res.statusCode} #{req.method} #{req.url} #{body}- #{req.headers["x-forwarded-for"] or req.connection.remoteAddress} - #{err}"
				e = new Pages.Error @, err
				e.beforeAction req
				e.render res
			@server = @app.listen @options.port
			logger.log "Listening on #{@options.port}"
			logger.warn "Warnings: #{__info.warn}" if __info.warn > 0
			logger.error "Errors: #{__info.error}" if __info.error > 0
			cb?()
		, 50

App.instance = __instance