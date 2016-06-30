module.exports = 
	colors: yes
	log: (message) ->
		console.log "#{new Date()} #{message}"
	warn: (message) ->
		if @colors
			console.warn "\x1b[33m#{new Date()} #{message}\x1b[0m"
		else
			console.warn "#{new Date()} #{message}"
	error: (message) ->
		if colors
			console.error "\x1b[31m#{new Date()} #{message}\x1b[0m"
		else
			console.error "#{new Date()} #{message}"