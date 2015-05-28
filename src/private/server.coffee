express = require 'express'
app = do express

app.get '/', (req, res) ->
	res.sendfile './public/index.html'

app.use(express.static 'public' )

app.listen 3050
console.log "Listening on http://localhost:" + 3050
