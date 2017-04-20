Page = require "./page"

module.exports = class Error extends Page
	constructor: (app, err) ->
		super app
		@message = "Unknown error"
		@message = err.toString() if err
	getTitle: -> @message
	getTemplate: -> "error"
	beforeAction: (req) -> @user = req.user if req.user
	getData: -> message: @message
	getResponse: ->
		new Page.HtmlResponse "error", @message, message: @message
		