express = require 'express'
app = do express

app.get '/', (req, res) ->
	res.sendfile 'public/index.html'

app.listen 8080