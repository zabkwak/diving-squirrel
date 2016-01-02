async = require "async"
fs = require "fs"
path = require "path"

logger = require "../logger"

module.exports =
	Error: require "./error"
	register: (dir, app, cb) ->
		fs.readdir dir, (err, files) ->
			return cb? err if err
			if files.length is 0
				logger.warn "\x1b[33mDirectory #{dir} is empty.\x1b[0m"
				return cb? no, []
			pages = []
			async.each files, (page, callback) =>
				p = new (require path.resolve dir, page) app
				p.register()
				pages.push p
				callback()
			, (err) ->
				cb? err, pages