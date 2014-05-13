express = require 'express'
app = do express

app.get '/', (req, res) ->
	res.sendfile './public/index.html'

app.use(express.static 'public' )

app.listen 3050