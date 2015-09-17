steps_dep = new Deps.Dependency()

Template.body.helpers
	tutorials: ->
		Meteor.subscribe('tutorials');
		return Tutorials.find {},
			sort:
				createdAt: -1

	Template.body.events
		"change .update-tutorial": (event, ui) ->
			event.preventDefault();

			window.windowthis = this
			window.windowevent = event
			window.windowui = ui

			tut_id = this._id
			tut_id ?= ui._id

			title = ui.title

			console.log $("#tutorial-" + tut_id + " form.update-tutorial :checkbox:checked").length > 0

			console.log $("#tutorial-" + tut_id + " input[name='publishMode']")
			console.log $("#tutorial-" + tut_id + " input[name='publishMode']").is(":checked")

			if $("#tutorial-" + tut_id + " form.update-tutorial :checkbox:checked").length > 0
				publishMode = "publish"
			else
				publishMode = "unpublish"


			console.log publishMode
			Meteor.call("updateTutorial", tut_id, title, publishMode)
			return false


Template.body.events "click .button": ->
	targetForm = $(event.target).closest(".step, .tutorial").find(".edit-form").first()
		.toggle('slide', { 'direction': 'right'}, 300)
			


Template.tutorial.events
	"click button.delete": ->
		r = confirm("Delete this tutorial? This cannot be undone.")
		if r == true 
			Tutorials.remove this._id

	"change .iconInput": (event, target) ->
		thistut = this._id
		FS.Utility.eachFile event, (file) ->
			Icons.insert file, (err, fileObj) ->
				Tutorials.update thistut,
					$set:
						icon_id: fileObj._id
#			$(".tutorial").find(".edit-form").hide('slide', { 'direction': 'right'}, 300);


Template.tutorial.rendered = ->	
	console.log("rendered")
	$('.lazyYT').lazyYT()
	if(Meteor.user())
		$( ".steps.sortable" ).sortable
			handle: ".sorthandle"
			start: (event, ui ) ->
				$(this).addClass("sorting");
			stop: (event, ui ) ->
				$(this).removeClass("sorting");
				$(this).children(".step").each (i, d) ->
					Meteor.call("updateStep", Blaze.getData(d)._id, i * 10)




Template.tutorial.helpers
	steps: ->
#			Meteor.subscribe "steps"
		Steps.find { tutorial_id: this._id },
			sort:
				ordinal: 1
	nodeIcon: ->
		Meteor.subscribe "icons"
		icon = Icons.findOne({_id:this.icon_id})
		if(icon)
			console.log icon
			imgurl = icon.url()
		else
			imgurl = DEFAULT_ICON
		return "<img src='" + imgurl + "'>"
	publishMode: ->
		if this.publishMode == "publish"
			return "publish"
		else
			return "unpublish"
	publishChecked: ->
		if this.publishMode == "publish"
			return "checked"
		else
			return ""


	

	
Template.step.helpers
	video_embedded: ->
		if this.video_url
			parseUrl = this.video_url.match(/(http|https):\/\/(?:www.)?(?:(vimeo).com\/(.*)|(youtube).com\/watch\?v=(.*?)$)/)
			if parseUrl
				if parseUrl[2] || parseUrl[3]
					vimeoID = parseUrl[3]
					embedUrl = '//player.vimeo.com/video/' + vimeoID
					return '<div class="lazyYT" data-vimeo-id="' + vimeoID + '"></div>'
				else
					youtubeID = parseUrl[5]
					embedUrl = '//www.youtube.com/embed/' + youtubeID
					return '<div class="lazyYT" data-youtube-id="' + youtubeID + '"></div>'

Deps.autorun ->
	steps_dep.depend()
	$('.lazyYT').lazyYT()

Template.step.events
	"click button.delete": ->
		r = confirm("Delete this step? This cannot be undone.")
		if r == true 
			Steps.remove this._id


Template.step.events "submit .update-step": ->
#		$(".step").find(".edit-form").hide('slide', { 'direction': 'right'}, 300);
	description = event.target.description.value
	video_url = event.target.video_url.value
	Steps.upsert this._id,
		$set:  
			tutorial_id: this.tutorial_id
			description: description
			video_url: video_url
			ordinal: 99999
			updatedAt: new Date() # current time
	if "new" in this
		event.target.description.value = ""
		event.target.video_url.value = ""
	steps_dep.changed()
	console.log "update-step"
	return false


Template.step.rendered = ->
	button = this.find('.button');



