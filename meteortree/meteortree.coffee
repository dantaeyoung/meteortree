Tutorials = new Mongo.Collection("tutorials")
Steps = new Mongo.Collection("steps")
Links = new Mongo.Collection("deps")
Icons = new Mongo.Collection("icons")

if Meteor.isClient
	
	# counter starts at 0
	Session.set "dep-mode", "False"
	nodes_dep = new Deps.Dependency()

	Template.body.helpers tutorials: ->
		if(Meteor.user())
			Tutorials.find {},
				sort:
					createdAt: -1
		else
			Tutorials.find 
				publishMode: "publish",
				sort:
					createdAt: -1

	Template.body.events "click .save-draft": (event) ->
		allTuts = Tutorials.find({}).fetch()
		_.each allTuts, (t) ->
			console.log t
			Tutorials.update t._id,
				$set:
					x: t.draft_x
					y: t.draft_y
		$("body").removeClass "draft-mode"
		$(".node").removeClass "draft-node"
		Session.set "draft-mode", "False"
	
	Template.body.events "click .discard-draft": (event) ->
		allTuts = Tutorials.find({}).fetch()
		_.each allTuts, (t) ->
			console.log t
			Tutorials.update t._id,
				$set:
					draft_x: t.x
					draft_y: t.y
		$("body").removeClass "draft-mode"
		$(".node").removeClass "draft-node"
		Session.set "draft-mode", "False"
	
	Template.body.events "submit .new-tutorial": (event) ->
		
		# This function is called when the new tutorial form is submitted
		title = event.target.title.value
		x = 15
		y = 15
		Tutorials.insert
			title: title
			publishMode: "draft"
			draft_x: x
			draft_y: y
			x: x
			y: y
			createdAt: new Date() # current time
			createdById: Meteor.userId()
			createdByUsername: Meteor.user().username
		# Clear form
		event.target.title.value = ""
		nodes_dep.changed
		
		# Prevent default form submit
		return false

	Template.tutorial.helpers steps: ->
		Steps.find
			tutorial_id: this._id


	Template.tutorial.events
		"click button.delete": ->
			Tutorials.remove this._id
		"click .uploadPanel .start" : ->
			Session.set("uploading-tutorial-id", this.uploadContext.tutorial_id)
			return false

	Template.step.helpers video_embedded: ->
		if this.video_url
			"<iframe width=\"420\" height=\"315\" src=\"" + this.video_url + "\" frameborder=\"0\" allowfullscreen></iframe>"

	Template.step.events
		"click button.delete": ->
			Steps.remove this._id

	Template.step.events "submit .update-step": ->
		description = event.target.description.value
		video_url = event.target.video_url.value
		ordinal = event.target.ordinal.value
		console.log event
		console.log this
		console.log this._id
		upsertDict = 
			tutorial_id: this.tutorial_id
			description: description
			video_url: video_url
			ordinal: ordinal
			createdAt: new Date() # current time
		console.log(upsertDict)
		Steps.insert
			tutorial_id: this.tutorial_id
			description: description
			video_url: video_url
			ordinal: ordinal
			createdAt: new Date() # current time
		###
		Steps.upsert 
			id: this._id
			,
			$set:  
					tutorial_id: this.tutorial_id
					description: description
					video_url: video_url
					ordinal: ordinal
					createdAt: new Date() # current time
		###
		if "new" in this
			event.target.description.value = ""
			event.target.video_url.value = ""
		return false

	Template.sectiontree.helpers nodes: ->
		if(Meteor.user())
			Tutorials.find {},
				sort:
					createdAt: -1
		else
			Tutorials.find {'publishMode':'draft'},
				sort:
					createdAt: -1

	Template.sectiontree.rendered = ->
		console.log("secitiontreerendred");

	Template.node.helpers
		xpos: ->
			if(Meteor.user())
				this.draft_x * GRID_MULTIPLIER
			else
				this.x * GRID_MULTIPLIER
		ypos: ->
			if(Meteor.user())
				this.draft_y * GRID_MULTIPLIER
			else
				this.y * GRID_MULTIPLIER
		nodehelper: ->
			nodes_dep.depend()
			console.log this
			that = this

			jsPlumb.ready ->

				if(Meteor.user())
					jsPlumb.draggable $(".node"),
						grid: [ GRID_MULTIPLIER, GRID_MULTIPLIER ]
						stop: (event, ui) -> # fired when an item is dropped
							$("body").addClass "draft-mode"
							Session.set "draft-mode", "True"
							console.log ui
							tut = Blaze.getData(ui.helper[0])
							$(".node#" + tut._id).addClass("draft-node")
							Tutorials.update tut._id,
								$set:
									draft_x: ui.position.left / GRID_MULTIPLIER
									draft_y: ui.position.top / GRID_MULTIPLIER
				drawLinks that._id


	Template.node.events "click": ->
		console.log this
		$(".tutorial").fadeOut(100);
		$(".tutorial#" + this._id).fadeIn(100);

	Template.node.events "click .change-dep": ->
		if(Meteor.user())
			unless Session.get("dep-mode") is "True"
				$("body").addClass "dep-mode"
				Session.set "dep-mode", "True"
				Session.set "dep-from", this._id
				Session.set "mouseX", this.draft_x * GRID_MULTIPLIER
				Session.set "mouseY", this.draft_y * GRID_MULTIPLIER
				$(".section-tree").bind "mousemove", (e) ->
					$(".section-tree").line Session.get('mouseX'),Session.get('mouseY'),e.pageX, e.pageY, {id: 'depline'}

			else
				$("body").removeClass "dep-mode"
				$(".section-tree").unbind "mousemove"
				$("#depline").remove()
				Session.set "dep-mode", "False"
				tut1_id = [ this._id, Session.get("dep-from") ].sort()[0]
				tut2_id = [ this._id, Session.get("dep-from") ].sort()[1]
				Session.set "dep-from", ""
				existingLinks = Links.find(
					tutorial1: tut1_id
					tutorial2: tut2_id
				).fetch()
				
				if existingLinks.length > 0
					console.log "removing dep"


					conns = jsPlumb.getConnections
						source:tut1_id
						target:tut2_id
					_.each conns, (c) ->
						jsPlumb.detach c
					
					_.each existingLinks, (d) ->
						Links.remove d._id

				else if tut1_id != tut2_id
					console.log "adding dep " + tut1_id + "-->" + tut2_id
					Links.insert
						tutorial1: tut1_id
						tutorial2: tut2_id
						createdAt: new Date() # current time
					nodes_dep.changed
					
	drawLinks = (from_id) ->
		_.each Links.find({tutorial1: from_id}).fetch(), (d) ->
			console.log d
			jsPlumb.connect
				source: $('#' + d.tutorial1)
				target: $('#' + d.tutorial2)
				anchor: [ "Left", "Right" ]

	Template.node.helpers
		nodeIcon: ->
			console.log this
			icon = Icons.findOne({tutorial_id:this._id})
			console.log icon
			if(icon)
				return "<img src='/uploads/" + icon.filename + "'>"
			else
				return ""

	Template.node.rendered = ->
		console.log "node renderd"

	Template.body.helpers
		allicons: ->
			return _.map(Icons.find({}).fetch(), (i) -> return i.filename;)

		
	Meteor.startup ->

		Uploader.finished = (index, file) ->
			Session.set("UploadedFile", file);
			console.log "Fdsfdsafdsa"
			console.log Session.get("uploading-tutorial-id")
			Icons.insert
				filename: file.name
				tutorial_id: Session.get("uploading-tutorial-id")
			Session.set("UploadedFile", null);
			Session.set("uploading-tutorial-id", null)

		$(document).ready ->
			jsPlumb.ready ->
				endpointOptions = { isSource:true, isTarget:true }; 
#				endpoint = jsPlumb.addEndpoint('elementId', endpointOptions);
				console.log $(".node")


	Accounts.ui.config
		passwordSignupFields: "USERNAME_ONLY"


if Meteor.isServer
	Meteor.startup ->
		UploadServer.init
			tmpDir: process.env.PWD + '/public/uploads/tmp'
			uploadDir: process.env.PWD + '/public/uploads/'
#			imageVersions: {thumbnailSmall: {width: 200, height: 200}}
