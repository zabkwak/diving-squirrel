# Diving Squirrel

Simple node.js framework for easy preparation of web sites using [express](https://www.npmjs.com/package/express) and [jade](https://www.npmjs.com/package/jade). 
It's written in [CoffeeScript](http://coffeescript.org/).

## Installation

```bash
$ npm install diving-squirrel
```

## Usage
```coffeescript
DS = require "diving-squirrel"
app = new DS.App
app.start()
```

## Creating page
```coffeescript
Page = (require "diving-squirrel").Page

module.exports = class Home extends Page
	getScripts: -> ["/script/script.js"]
	getRoutes: ->
		[
			new Page.Route "/", (req, res, next) ->
				next no, new Page.HtmlResponse "home", "Home"
			new Page.Route "/json", (req, res, next) ->
				next no, new Page.JsonResponse data: "some data"
			new Page.Route "/login", (req, res, next) ->
				res.loginUser 1
				res.redirect "/"
		]

```

## Methods

### Class Page.Route
constructor: (route, method = "GET", cb = null)
**route** route for register
**method** http method
**callback** express callback with (req, res, next) parameters

### Class Page.HtmlResponse
constructor: (template, title, data, styles = [], scripts = [])

### Class Page.JsonResponse
constructor: (data)