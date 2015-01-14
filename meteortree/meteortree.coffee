Tutorials = new Mongo.Collection("tutorials")
Steps = new Mongo.Collection("steps")
Deps = new Mongo.Collection("deps")
if Meteor.isClient
	
	# counter starts at 0
	Session.set "dep-mode", "False"
	Template.body.helpers tutorials: ->
		Tutorials.find {},
			sort:
				createdAt: -1

	Template.body.events "submit .new-tutorial": (event) ->
		
		# This function is called when the new tutorial form is submitted
		title = event.target.title.value
		x = event.target.x.value
		y = event.target.y.value
		Tutorials.insert
			title: title
			x: x
			y: y
			createdAt: new Date() # current time

		# Clear form
		event.target.title.value = ""
		
		# Prevent default form submit
		return false

	Template.tutorial.helpers steps: ->
		Steps.find
			tutorial_id: this._id
			sort:
				ordinal: -1
				createdAt: -1


	Template.tutorial.events
		"click button.xplus": ->
			Tutorials.update this._id,
				$set:
					x: parseInt(this.x) + 1


		"click button.xminus": ->
			Tutorials.update this._id,
				$set:
					x: parseInt(this.x) - 1


		"click button.yplus": ->
			Tutorials.update this._id,
				$set:
					y: parseInt(this.y) + 1


		"click button.yminus": ->
			Tutorials.update this._id,
				$set:
					y: parseInt(this.y) - 1


		"click button.delete": ->
			Tutorials.remove this._id

	Template.step.helpers video_embedded: ->
		"<iframe width=\"420\" height=\"315\" src=\"" + this.video_url + "\" frameborder=\"0\" allowfullscreen></iframe>"

	Template.step.events "submit .update-step": ->
		description = event.target.description.value
		video_url = event.target.video_url.value
		ordinal = event.target.ordinal.value
		console.log event
		console.log this
		console.log this._id
		Steps.upsert this._id,
			$set:
				tutorial_id: this.tutorial_id
				description: description
				video_url: video_url
				ordinal: ordinal
				createdAt: new Date() # current time

		if "new" of this
			event.target.description.value = ""
			event.target.video_url.value = ""
		return false

	Template.sectiontree.helpers nodes: ->
		Tutorials.find {},
			sort:
				createdAt: -1


	Template.sectiontree.rendered = ->
		power = "boo"
		#drawDeps this.data._id
		console.log("secitiontreerendred");
		$(".node").each (i) -> 
			console.log("whoa");
			tut = Blaze.getData $(this)
			console.log tut
		jsPlumb.ready ->
			dynamicAnchors = [ "Left", "Right" ]
			jsPlumb.draggable $(".node"),
				grid: [ GRID_MULTIPLIER, GRID_MULTIPLIER ]
				stop: (event, ui) -> # fired when an item is dropped
					tut = Blaze.getData(ui.helper[0])
					Tutorials.update tut._id,
						$set:
							x: ui.position.left / GRID_MULTIPLIER
							y: ui.position.top / GRID_MULTIPLIER


	Template.node.helpers
		xpos: ->
			this.x * GRID_MULTIPLIER

		ypos: ->
			this.y * GRID_MULTIPLIER

	Template.node.events "click .change-dep": ->
		unless Session.get("dep-mode") is "True"
			$("body").addClass "dep-mode"
			Session.set "dep-mode", "True"
			Session.set "dep-from", this._id
			$(".section-tree").bind "mousemove", (e) ->
				console.log e.pageX + "," + e.pageY

		else
			$("body").removeClass "dep-mode"
			$(".section-tree").unbind "mousemove"
			Session.set "dep-mode", "False"
			tut1_id = [ this._id, Session.get("dep-from") ].sort()[0]
			tut2_id = [ this._id, Session.get("dep-from") ].sort()[1]
			Session.set "dep-from", ""
			existingDeps = Deps.find(
				tutorial1: tut1_id
				tutorial2: tut2_id
			).fetch()
			if existingDeps.length > 0
				console.log "removing dep"
				_.each existingDeps, (d) ->
					Deps.remove d._id

			else
				console.log "adding dep " + tut1_id + "-->" + tut2_id
				Deps.insert
					tutorial1: tut1_id
					tutorial2: tut2_id
					createdAt: new Date() # current time

	drawDeps = (from_id) ->
		_.each Deps.find({tutorial1: from_id}).fetch(), (d) ->
			console.log d
			jsPlumb.connect
				source: $('#' + d.tutorial1)
				target: $('#' + d.tutorial2)
				dynamicAnchors: [ "Left", "Right" ]


	Template.node.rendered = ->
		console.log $(".node")
		$(".node").each (i) -> 
			tut = Blaze.getData this
#		$(".node").each (i) -> 
#			tut = Blaze.getData this

		###
		jsPlumb.ready ->
			jsPlumb.draggable $(".node"),
				grid: [ GRID_MULTIPLIER, GRID_MULTIPLIER ]
				stop: (event, ui) -> # fired when an item is dropped
					tut = Blaze.getData(ui.helper[0])
					Tutorials.update tut._id,
						$set:
							x: ui.position.left / GRID_MULTIPLIER
							y: ui.position.top / GRID_MULTIPLIER

		$(".node").draggable
			grid: [ GRID_MULTIPLIER, GRID_MULTIPLIER ]
			stop: (event, ui) -> # fired when an item is dropped
				tut = Blaze.getData(ui.helper[0])
				Tutorials.update tut._id,
					$set:
						x: ui.position.left / GRID_MULTIPLIER
						y: ui.position.top / GRID_MULTIPLIER
			drag: (e) ->
				console.log(e.target);
				tut = Blaze.getData(e.target)
				jsPlumb.repaint(e.target);
				$(e.target).find('._jsPlumb_endpoint_anchor_').each (i, e) ->
					console.log($(e))
					jsPlumb.repaint($(e))
		###

if Meteor.isServer
	Meteor.startup ->


# code to run on server at startup
