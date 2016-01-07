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
**pages** Directory for page classes. Default: ./pages  
**name**  Name of the app. You should set it. Default: Diving Squirrel  
**baseUrl** URL for creating links in the app. Default: ""  
**styles** List of styles for entire project. Default: []  
**scripts** List of scripts for entire project. Default: []  
**prodcution** Flag for production environment. Default: false  
**onLoggedUser: (identificator, callback)** Function called in the middleware for checking if user is logged. Identificator is signed cookie with key *u*.Callback has two parameters. Error and user data from the onLoggedUser method. If cookie doesn't exist function is skipped. Default: Function just pass empty object to the callback  

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
**link** Page.link alias  
**date** JS Date instance  

## Docs

### Class App
Base setup of the app. It uses express methods. This class is a singleton. Http methods are registered via Page classes.
```coffeescript
### Creates the application.
@param options 
###
constructor: (options)
###
Registers express middleware.
@param route
@param callback
###
use: (route, callback)
###
Registers get route.
@param route
@param callback
###
get: (route, callback)
###
Registers post route.
@param route
@param callback
###
post: (route, callback) 
###
Registers put route.
@param route
@param callback
###
put: (route, callback)
###
Registers head route.
@param route
@param callback
###
head: (route, callback) 
###
Registers delete route.
@param route
@param callback
###
delete: (route, callback)
###
Starts the app.
###
start: ()
```

#### Response methods in the callback
**loginUser: (identificator)** Saves the identificator to signed cookie *u*.  
**logoutUser: ()** Clears the cookie *u*.  
**send401: (message = "Unauthorized request")** Sets 401 http code and sends the message.  
**send404: (message = "Page not found")** Sets 404 http code and sends the message.  

### Class Page
Base class for creating pages. Whole process is automatic if you define getRoutes function (the example above).
```coffeescript
###
Creates new page.
@param app Instance of the application.
###
constructor: (app)
###
Default response if none of page responses is passed in render function.
@return Page Response
###
getResponse: ()
###
Checks if the page uses layout.jade.
@return bool
###
useLayout: ()
###
Gets the list of the Page.Route instances.
@return array
###
getRoutes: ()
###
Function is called before the Page.Route callback.
@param req Request from the express.
###
beforeAction: (req)
###
Checks if login is required. If true user must must be passed in req parameter in Page.Route callback otherwise 401 error is thrown.
@return bool
###
requireLogin: ()
###
Gets the list of styles for this Page.
@return array
###
getStyles: ()
###
Gets the list of scripts for this Page.
@return array
###
getScripts: ()
###
Registers the page's routes to the app. 
###
register: ()
###
Compiles the jade template to the html string.
@param path Relative path to the template from the *options.views* directory.
@param data Data to pass to the template.
@return string
###
compilePath: (path, data = {})
###
Renders the page' route by its type. 
@param res Response from the express.
@param response Response instance from Page.
###
render: (res, response)

```

### Class Page.Route
```coffeescript
###
Creates route with callback for the http request.
@param route Route for register 
@param method Http method
@param callback Express callback with (req, res, next) parameters 
###
constructor: (route, method = "get", callback = null)
```

### Class Page.HtmlResponse
```coffeescript
###
Creates HTML response. The data are passed to the template. The template is rendered.
@param template Relative path to the jade template in the views directory.
@param title Title of the page.
@param data Data passed to the template.
@param styles List of styles added to the route.
@param scripts List of styles added to the route.
###
constructor: (template, title, data = {}, styles = [], scripts = [])
```

### Class Page.JsonResponse
```coffeescript
###
Creates JSON resposne. The data are shown as a json string.
@param data Data to show.
###
constructor: (data)
```

### Page.link
```coffeescript
###
Creates link from the *options.baseUrl*, route and adds params to the url query.
@param route 
@param params
###
Page.link: (route = "", params = {})
```