###
COMMODORE: fancy.js
Nothing important here, just fancy stuff like animations, jQuery, etc. Again, source written in Coffeescript.
Rodolfo Palma O. rpalmaotero[at]gmail[dot]com
###

class Lightbox 
	constructor: (@options) ->
		console.log "LOG[lightbox]: Creating lightbox."
		
		@lightboxWrapper = $("<div></div>").addClass("lightbox_wrapper").hide().appendTo("body");
		@extraData = if @options.extraData? then @options.extraData else {}

		do @fillTemplateContent
		do @fillUserContent
		do @addEscapeKeyListener

	show: ->
		console.log "LOG[lightbox]: Showing lightbox."
		that = @
		@lightboxWrapper.show 100, ->
			if that.options.form?
				do $(@).find("input[type='text']").focus

	hide: ->
		console.log "LOG[lightbox]: Hiding lightbox."
		@lightboxWrapper.hide 100

	fillTemplateContent: ->
		console.log "LOG[lightbox]: Filling lightbox with UI elements."
		@lightboxInner = $("<div></div>").addClass("lightbox_inner").appendTo(@lightboxWrapper)
		@lightboxContent = $("<div></div>").addClass("lightbox_content").appendTo(@lightboxInner)
		@closeButton = $("<button type='button' class='close' aria-hidden='true'></button>")
			.html("&times;")
			.appendTo(@lightboxContent)
			.click =>
				do @hide

	fillUserContent: ->
		console.log "LOG[lightbox]: Filling lightbox with user content."
		@lightboxUserContent = $("<div></div>").addClass("lightbox_user_content").appendTo(@lightboxContent)

		console.log "LOG[lightbox]: AJAX call to #{@options.url}"
		$.get @options.url, (data) =>
			@lightboxUserContent.html data

			if @options.form?
				do @addFormListener

			do @show

	addFormListener: ->
		console.log "LOG[lightbox]: Adding submit event listener to user's form."
		that = @

		@lightboxUserContent.find("form").submit (e) ->
			console.log "LOG[lightbox]: User's form submitted, handling it."
			that.options.callback(do $(@).serializeArray, that.extraData) 

			do that.hide
			return false

	addEscapeKeyListener: ->
		$(document).keyup (e) =>
			if e.keyCode == 27
				do @hide

###
The so loved and hated jQuery
###

$ ->
	# blablabla