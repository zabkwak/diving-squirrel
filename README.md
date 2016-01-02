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
This usage will create the app with default options. 

### Options
**port** Port where the app listens. Default: 8080  
**views** Base directory of jade templates. Default: ./views  
**cookieSecret** Secret for signing cookies. You should set it. Default: \_\_cookieSecret\_\_  
**static** Directory for express static files. Default: ./public  
**pages**   
**name**  
**baseUrl**   
**styles** List of styles for entire project. Default: []  
**scripts** List of scripts for entire project. Default: []  
**prodcution**  
**onLoggedUser**  

## Templates
If you will use HTML responses, you should create layout.jade in the *options.views* directory. If the file doesn't exist template of the route is used.  
Variables passed to the layout.jade:  
**title** Title of the page created from the name of the page and name of the application.  
**name** Application name.  
**styles** List of styles loaded in the layout. It's taken from the *options.styles*.   
**scripts** List of scripts loaded in the layout. It's taken from the *options.scripts*.  
**user** Logged user.  
**content** Content of the route template.  

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

## Template functions
Functions are passed to all templates in *f* variable.
**link**  
**date** 

## Docs

### Class App
```coffeescript
constructor: (options)
use: (route, callback)
get: (route, callback)
post: (route, callback) 
put: (route, callback)
head: (route, callback) 
delete: (route, callback)
start: ()
```

### Class Page
```coffeescript
constructor: (app)
getResponse: ()
useLayout: ()
getRoutes: ()
beforeAction: (req)
requireLogin: ()
getStyles: ()
getScripts: ()
register: ()
compilePath: (path, data = {})
render: (res, response)

```

### Class Page.Route
```coffeescript
###
Creates route with callback for the http request.
@param route route for register 
@param method http method
@param callback express callback with (req, res, next) parameters 
###
constructor: (route, method = "GET", callback = null)
```

### Class Page.HtmlResponse
```coffeescript
###
Creates HTML response. The data are passed to the template. The template is rendered.
@param template relative path to the jade template in the views directory
@param title title of the page
@param data data passed to the template
@param styles list of styles added to the route
@param scripts list of styles added to the route
###
constructor: (template, title, data = {}, styles = [], scripts = [])
```

### Class Page.JsonResponse
```coffeescript
###
Creates JSON resposne. The data are shown as a json string.
@param data data to show
###
constructor: (data)
```

### Page.link
```coffeescript
###
Creates link from the options.baseUrl, route and adds params to the url query.
@param route 
@param params
###
Page.link: (route = "", params = {})
```