module.exports = 
	log: (message) ->
		console.log "#{new Date()} #{message}"
	warn: (message) ->
		console.warn "\x1b[33m#{new Date()} #{message}\x1b[0m"
	error: (message) ->
		console.warn "\x1b[31m#{new Date()} #{message}\x1b[0m"