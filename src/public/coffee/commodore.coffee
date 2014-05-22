###
COMMODORE: commodore.js
Main javascript file. Source is written in Coffeescript. Totally framework independent class.
Rodolfo Palma O. rpalmaotero[at]gmail[dot]com
###
# Companies: geocoded locations stored in array.
companies = [
	[-33.437558, -70.64334],
	[-33.432616, -70.647864],
	[-33.4417574,-70.6342405],
	[-33.4367464,-70.6579166],
	[-33.4461476,-70.6538236],
	[-33.4496043,-70.6610847],
	[-33.4568944,-70.6370383],
	[-33.432369, -70.647824],
	[-33.440087,-70.66659],
	[-33.4579181,-70.640688],
	[-33.449714,-70.668046],
	[-33.439877,-70.664645],
	[-33.433555,-70.6226514],
	[-33.4212346,-70.5975754],
	[-33.4081047,-70.5477131],
	[-33.4637993,-70.702246],
	[-33.460317, -70.671884],
	[-33.3922319,-70.5627407],
	[-33.364548, -70.514851],
	[-33.4061399,-70.5598305],
	[-33.403532,-70.708908],
	[-33.419807,-70.669408],
]

class Commodore
	constructor: (@companies, @gmaps) ->
		# Setting up the enviroment
		do @displayMap
		do @fillSelectionList
		do @addSelectionListListeners
		do @addMapMarkers
		do @addMapClickListener
		do @addSimulationButtonListener

		@directionsService = new @gmaps.DirectionsService

		@directions = []
		@results = {}

	displayMap: ->
		mapOptions = 
		    zoom: 12
		    center: new @gmaps.LatLng(-33.4406259,-70.638071)

		console.log "LOG: Setting up the map."
		@map = new @gmaps.Map document.getElementById("mapa"), mapOptions

	getCardinalName: (i) ->
		cardinal = [
			"1ra", 
			"2da",
			"3ra",
			"4ta",
			"5ta",
			"6ta",
			"7ma",
			"8ta",
			"9na",
			"10ma",
			"11ma",
			"12da",
			"13ra",
			"14ta",
			"15ta",
			"16ta",
			"17ma",
			"18va",
			"19na",
			"20ma",
			"21ra",
			"22da"
		]

		return "#{cardinal[i]} Compañía" 

	fillSelectionList: ->
		selectionList = document.getElementById "companias"
		for value, i in @companies
			label = document.createElement "label"
			input = document.createElement "input"
			input.setAttribute "type", "checkbox"
			input.checked = true
			input.setAttribute "value", i + 1
			input.setAttribute "name", "companias"

			label.innerText = @getCardinalName i
			label.insertBefore input, label.firstChild

			console.log "LOG: Creating #{i + 1}th company checkbox."
			selectionList.appendChild label
			
			@selectionList = selectionList

	addSelectionListListeners: ->
		buttons = document.getElementById("seleccion_controles").getElementsByTagName("button")

		for button in buttons
			that = @
			button.addEventListener "click", ->
				dataset = @dataset
				include = @dataset.selection_include?
				values = (@dataset.selection_include || @dataset.selection_exclude).split ","

				for input in that.selectionList.getElementsByTagName("input")
					if input.value in values
						input.checked = include
					else  
						input.checked = !include

	addMapMarkers: ->
		@markers = []
		for companie, i in @companies
			position = new @gmaps.LatLng(companie[0], companie[1])
			marker = new @gmaps.Marker({
				position: position
				title: "BOMBEROS"
				icon: './i/fireman-26.png'
			})
			console.log "LOG: Creating #{i + 1}th company marker."
			marker.setMap @map
			@markers[i] = marker

	addMapClickListener: ->
		that = @
		@gmaps.event.addListener @map, 'click', (data) ->
			that.emergency?.setMap null
			that.emergency = new that.gmaps.Marker({
				position: data.latLng
				title: "EMERGENCIA"
				icon: './i/fire_element-26.png'
			})

			console.log "LOG: Creating emergency point."
			that.emergency.setMap that.map

	addSimulationButtonListener: ->
		button = document.getElementById("controles_simular").getElementsByTagName("button")[0]
		that = this
		button.addEventListener 'click', ->
			do that.simulate

	simulate: ->
		# Check if there is actually an emergency point
		if not @emergency?.getPosition
			console.log "ERROR: There is no emergency point defined."
			return

		console.log "LOG: Simulating..."

		# Erase previous routes
		for route, i in @directions
			route.setMap null
		
		@directions = []
		@results = []

		calculateRoute = (val, i, j) =>
			request =
				origin: do @markers[val - 1].getPosition
				destination: do @emergency.getPosition
				travelMode: @gmaps.TravelMode.DRIVING

			console.log "LOG: from #{val}th to emergency point."

			that = @

			@directionsService.route request, (res, status) =>
				console.log status
				displayRoute res
				analyzeRoute res, val

				if i == j
					console.log "LOG: Route simulation has finished."
					do @sortResults

		displayRoute = (res) =>
			directionsRenderer = new @gmaps.DirectionsRenderer
			directionsRenderer.setMap @map
			directionsRenderer.setDirections res

			@directions.push directionsRenderer

		analyzeRoute = (res, val) =>
			@results.push 
				screenName: @getCardinalName(val - 1)
				duration: res.routes[0].legs[0].duration.value

		j = 0
		for input in @selectionList.getElementsByTagName "input"			
			if input.checked
				j++
				i = j
				val = input.value
				do (val, j) ->
					setTimeout ->
						calculateRoute val, i, j
					, 600 * j

	sortResults: ->
		console.log "LOG: Sorting simulation results."

		compare = (a,b) ->
			if a.duration < b.duration
				return -1
			if a.duration > b.duration
				return 1
			return 0

		@results.sort compare

		do @displayResults

	displayResults: ->
		text = "#####   RESULTADOS SIMULACIÓN   #####\n"
		tmpTextArray = []

		for result, i in @results
			tmpTextArray.push "#{i + 1}) #{result.screenName}: #{result.duration}"
		
		text += tmpTextArray.join "\n"

		alert text

# Init everything...
console.log "LOG: Commodore initialization"
google.maps.event.addDomListener window, 'load', new Commodore(companies, google.maps)