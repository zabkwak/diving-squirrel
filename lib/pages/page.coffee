jade = require "jade"
async = require "async"
qs = require "querystring"
url = require "url"
fs = require "fs"
Path = require "path"

_getLink = (route) ->
	if route isnt "/" and route.lastIndexOf("/") is route.length - 1
		route = route.substr 0, route.length - 1
	route

module.exports = class Page
	constructor: (@app)->
	getResponse: -> throw "getResponse is not defined"
	useLayout: -> yes
	getRoutes: -> []
	beforeAction: (req) ->
	requireLogin: -> no
	getStyles: -> []
	getScripts: -> []
	register: ->
		async.each @getRoutes(), (route, callback) =>
			unless route instanceof Page.Route
				console.warn "Invalid route", route
				return callback()
			console.log "Registered route #{route.method.toUpperCase()} #{route.route}"
			@app[route.method] route.route, (req, res, next) =>
				@user = req.user
				return res.send401() if @requireLogin() and not @user
				@beforeAction req
				route.callback req, res, (err, response) =>
					return next err if err
					if response instanceof HtmlResponse
						@render res, response
					else if response instanceof JsonResponse
						res.json response.data
					else
						next "Invalid response"
			callback()

	compileTemplate: (path, data = {}) ->
		(jade.compileFile "#{@app.options.views}/#{path}.jade") _getVariables data

	render: (res, response) ->
		response = @getResponse() unless response
		templatePath = "#{@constructor.name.toLowerCase()}/#{response.template}"
		if @constructor.name.toLowerCase() is "error"
			templatePath =  (Path.relative @app.options.views, "#{__dirname}/../views") + "/error"
		return res.render templatePath, _getVariables response.data unless @useLayout()
		return res.render templatePath, _getVariables response.data unless fs.existsSync "#{@app.options.views}/layout.jade"
		try
			content = @compileTemplate templatePath, _getVariables response.data
			res.render "layout", _getVariables
				title: "#{response.title} | #{@app.options.name}"
				name: @app.options.name
				user: @user
				content: content
				styles: @app.options.styles.concat @getStyles(), response.styles
				scripts: @app.options.scripts.concat @getScripts(), response.scripts
		catch e 
			console.error e
			res.send404()
			
	_getVariables = (data) ->
		o = 
			f:
				link: Page.link
				date: new Date
		o[k] = v for k, v of data
		return o

Page.Route = class Route
	constructor: (route, method, callback) ->
		if typeof method is "function"
			callback = method
			method = "get"
		@route = _getLink route
		@method = method
		@callback = callback

Page.JsonResponse = class JsonResponse
	constructor: (@data) ->

Page.HtmlResponse = class HtmlResponse
	constructor: (@template, @title, @data, @styles = [], @scripts = []) ->

Page.link = (route = "", params = {}) ->
	App = require "../app"
	route = "/#{route}" if route[0] isnt "/"
	p = ""
	p = "?#{qs.stringify params}" if Object.keys(params).length > 0
	App.config.baseURL + _getLink "#{route}#{p}"