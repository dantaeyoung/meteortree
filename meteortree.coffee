Tutorials = new Mongo.Collection("tutorials")
Steps = new Mongo.Collection("steps")
Links = new Mongo.Collection("deps")
Courses = new Mongo.Collection("courses")
Weeks = new Mongo.Collection("weeks")
Icons = new FS.Collection("icons", {
  stores: [new FS.Store.GridFS("icons")]
});

Accounts.config({forbidClientAccountCreation: true})

if Meteor.isClient

	window.steps = Steps
	SkillTreeBezier = ->
		_super =  jsPlumb.Connectors.AbstractConnector.apply(this, arguments);

		this.type = "SkillTreeBezier" 
		this._compute = (paintInfo) ->

			x1=paintInfo.sx
			y1=paintInfo.sy
			x2=paintInfo.tx
			y2=paintInfo.ty

			#segment to end point
			_super.addSegment this, "Bezier",
				x1:x1
				y1:y1
				x2:x2
				y2:y2
				cp1x: ((x2 + x1) / 2 - (Math.sqrt(y1 + y2) / 2)) 
				cp1y: y1,
				cp2x: ((x2 + x1) / 2 + (Math.sqrt(y1 + y2) / 2))
				cp2y: y2
	jsPlumbUtil.extend(SkillTreeBezier, jsPlumb.Connectors.AbstractConnector);
	jsPlumb.registerConnectorType(SkillTreeBezier, "SkillTreeBezier");


	Session.set "dep-mode", "False"
	Session.set "nodes-rendered", 0
	nodes_dep = new Deps.Dependency()
	steps_dep = new Deps.Dependency()
	jsPlumb.setContainer($("#jsPlumbContainer"))
	jsPlumb.Defaults.Connector = [ "SkillTreeBezier", { curviness: 35, cornerRadius: 30 } ]
	jsPlumb.Defaults.PaintStyle = { strokeStyle:"gray", lineWidth:1 }
	jsPlumb.Defaults.EndpointStyle = { radius:3, fillStyle:"gray" }
	jsPlumb.Defaults.Anchor = [ "Left", "Right" ]

	endDepMode = (end_id) ->
		$("body").removeClass "dep-mode"
		$(".section-tree").unbind "mousemove"
		$("#depline").remove()
		Session.set "dep-mode", "False"
		tut1_id = [ end_id, Session.get("dep-from") ].sort()[0]
		tut2_id = [ end_id, Session.get("dep-from") ].sort()[1]
		Session.set "dep-from", ""
		Meteor.subscribe("links")
		existingLinks = Links.find(
			tutorial1: tut1_id
			tutorial2: tut2_id
		).fetch()
		
		if existingLinks.length > 0
			console.log "removing dep"
			conns = jsPlumb.getConnections
				source: $("#node-" + tut1_id)
				target: $("#node-" + tut2_id)
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
		drawLinks(tut1_id)

	Template.body.helpers
		tutorials: ->
			Meteor.subscribe('tutorials');
			return Tutorials.find {},
				sort:
					createdAt: -1
	
		loggedin: ->
			if(Meteor.user())
				return "logged-in"
			else
				return "not-logged-in"

	Template.body.events
		"click .save-draft": (event) ->
			if(Meteor.user())
				allTuts = Tutorials.find({}).fetch()
				_.each allTuts, (t) ->
					Meteor.call("saveTutorialLocation", t, "save")
				$("body").removeClass "draft-mode"
				$(".node").removeClass "draft-node"
				Session.set "draft-mode", "False"
		
		"click .discard-draft": ->
			if(Meteor.user())
				allTuts = Tutorials.find({}).fetch()
				_.each allTuts, (t) ->
					Meteor.call("saveTutorialLocation", t, "discard")
				$("body").removeClass "draft-mode"
				$(".node").removeClass "draft-node"
				Session.set "draft-mode", "False"
				jsPlumb.repaintEverything()

		
		"submit .new-tutorial": (event) ->
			event.preventDefault()

			Meteor.call "addTutorial" 
			# Clear form
			event.target.title.value = ""
			nodes_dep.changed
			

		"change .update-tutorial": (event, ui) ->
			event.preventDefault();

			window.windowthis = this
			window.windowevent = event
			window.windowui = ui

			tut_id = this._id
			tut_id ?= ui._id

#			$(".tutorial").find(".edit-form").hide('slide', { 'direction': 'right'}, 300);
			title = event.target.title.value

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




	Template.sectiontree.helpers nodes: ->
		Meteor.subscribe("tutorials")
		return Tutorials.find {},
			sort:
				createdAt: -1

	Template.sectiontree.rendered = ->
		if(!this._rendered)
			this._rendered = true

	Template.sectioncourses.helpers
		courses: ->
			Meteor.subscribe("courses")
			return Courses.find {},
				sort:
					createdAt: -1

	Template.sectioncourses.events 

		"submit form.new-course": ->
			event.preventDefault()
			Courses.insert
				title: 'course title'
				publishMode: "unpublish"
				createdAt: new Date() # current time
				createdById: Meteor.userId()
				createdByUsername: Meteor.user().username
				# Clear form

	Template.course.events
		"click .add-week-button": (event) ->
			event.preventDefault()

			Weeks.insert
				title: "new week"
				ordinal: 99999
				nodes: []
				course_id:  this._id
				createdAt: new Date() # current time

		"click .delete-course-button": (event) ->
			r = confirm("Delete this course? This cannot be undone.")
			if r == true 
				Courses.remove this._id

		"mouseover .course-title": (event) ->
			$(".courseHighlight").removeClass("courseHighlight");
			$("#course-" + this._id).addClass("courseHighlight");
			_.each $("#course-" + this._id).find(".week"), (d) ->
				_.each Blaze.getData(d).nodes, (n) ->
					$("#node-" + n).addClass "courseHighlight" 

		"mouseout .course-title": (event) ->
			$(".courseHighlight").removeClass("courseHighlight");


		"mouseover .week": (event) ->
			$(".weekHighlight").removeClass("weekHighlight");
			$("#week-" + this._id).addClass("weekHighlight");
			unless Session.get("week-mode") is "True" 
				console.log this
				_.each this.nodes, (n) ->
					$("#node-" + n).addClass "weekmodeHighlight" 

		"mouseout .week": (event) ->
			$(".weekHighlight").removeClass("weekHighlight");
			unless Session.get("week-mode") is "True" 
				$(".weekmodeHighlight").removeClass "weekmodeHighlight"

		"click .week": (event) ->
			if(Meteor.user())
				if Session.get("week-mode-from") == this._id
					Session.set "week-mode", "False" 
					Session.set "week-mode-from", ""
					$(".weekfrom").removeClass("weekfrom")
					$("body").removeClass "week-mode"
				else
					Session.set "week-mode", "True" 
					Session.set "week-mode-from", this._id

					$(".weekmodeHighlight").removeClass "weekmodeHighlight"
					$(".weekfrom").removeClass("weekfrom")

					$("body").addClass "week-mode"
					$(event.target).addClass("weekfrom")

					_.each this.nodes, (n) ->
						$("#node-" + n).addClass "weekmodeHighlight" 

		"click .publishMode": (event) ->
			if this.publishMode == "publish"
				Courses.update this._id,
					$set:  
						publishMode: "unpublish"
						updatedAt: new Date() # current time
			else
				Courses.update this._id,
					$set:  
						publishMode: "publish"
						updatedAt: new Date() # current time



	Template.week.events
		"click .week .delete": (event) ->
			r = confirm("Delete this week? This cannot be undone.")
			if r == true 
				Weeks.remove this._id


	Template.course.helpers
		weeks: ->
			Meteor.subscribe "weeks"
			return Weeks.find {course_id: this._id},
				sort:
					ordinal: 1
		publishModeIcon: ->
			if this.publishMode == "publish"
				return '<i class="fa fa-eye publish"></i>'
			else
				return '<i class="fa fa-eye-slash unpublish"></i>'


	Template.course.rendered = ->
		if(Meteor.user())
			$( ".weeks.sortable" ).sortable
				handle: ".sorthandle"
				start: (event, ui ) ->
					$(this).addClass("sorting");
				stop: (event, ui ) ->
					$(this).removeClass("sorting");
					$(this).children(".week").each (i, d) ->
						Weeks.update Blaze.getData(d)._id,
							$set:  
								ordinal: i * 10
								updatedAt: new Date() # current time
							(error) -> 
								console.log error
		


		
	Template.node.helpers
		xpos: ->
			if(Meteor.user())
				this.draft_x * GRID_MULTIPLIER_X
			else
				this.x * GRID_MULTIPLIER_X
		ypos: ->
			if(Meteor.user())
				this.draft_y * GRID_MULTIPLIER_Y
			else
				this.y * GRID_MULTIPLIER_Y
		draftMode: ->
			nodes_dep.depend()
			that = this
			if this.draft_y != this.y or this.draft_x != this.x
				$("body").addClass "draft-mode"
				return "draft-node"


	Template.body.events "click .button": ->
		targetForm = $(event.target).closest(".step, .tutorial").find(".edit-form").first()
			.toggle('slide', { 'direction': 'right'}, 300)
				

	Template.node.events "click": (event) ->
		tutid = this._id
		if Session.get("dep-mode") is "True" 
			endDepMode(this._id)
		else 
			unless Session.get("week-mode") is "True" 
				console.log this
				$(".tutorial").fadeOut(50);
				console.log "#tutorial-" + tutid
				$("#tutorial-" + tutid).fadeIn(50);
#				window.location.hash = tutid
			else
				weekfrom = Session.get("week-mode-from")
				weeksnodes = Weeks.findOne(_id: weekfrom).nodes
				if(tutid in weeksnodes)
					$("#node-" + tutid).removeClass "courseHighlight" 
					weeksnodes = _.without(weeksnodes, tutid)
				else 
					$("#node-" + tutid).addClass "courseHighlight" 
					weeksnodes.push(tutid)
				Weeks.update weekfrom,
					$set:
						nodes: weeksnodes

	Template.node.events "click .change-dep": ->
		if(Meteor.user())

			console.log this
			unless Session.get("dep-mode") is "True"
				$("body").addClass "dep-mode"
				Session.set "dep-mode", "True"
				Session.set "dep-from", this._id
				Session.set "mouseX", this.draft_x * GRID_MULTIPLIER_X
				Session.set "mouseY", this.draft_y * GRID_MULTIPLIER_Y
				$(".section-tree").bind "mousemove", (e) ->
					$(".section-tree").line Session.get('mouseX'),Session.get('mouseY'),e.offsetnX, e.offsetY, {id: 'depline'}
			else
				endDepMode(this._id)
					

	
	drawLinks = (from_id) ->
		Meteor.subscribe "links"
		Meteor.subscribe "tutorials"

		console.log "drawLinks"

		tut1PublishMode = Tutorials.findOne({_id: from_id}).publishMode

		console.log tut1PublishMode

		console.log Links.find({}).fetch()

		_.each Links.find({tutorial1: from_id}).fetch(), (d) ->
			console.log "yeah!"
			console.log d
			tut2PublishMode = Tutorials.findOne({_id: d.tutorial2}).publishMode

			jsPlumb.connect
				source: $('#node-' + d.tutorial1)
				target: $('#node-' + d.tutorial2)


	Template.node.helpers
		nodeIcon: ->
			icon = Icons.findOne({_id:this.icon_id})
			if(icon)
				imgurl = icon.url()
			else
				imgurl = DEFAULT_ICON
			return "<img src='" + imgurl + "'>"
				

				


	Template.node.rendered = ->

		Session.set("nodes-rendered", Session.get("nodes-rendered") + 1)

		Meteor.subscribe "tutorials"
		Meteor.subscribe "links"

		tuts = Tutorials.find {},
			sort:
				createdAt: -1
		tutcount = tuts.count()
		if(Session.get("nodes-rendered") == tutcount)
			_.each tuts.fetch(), (t) ->
				drawLinks t._id


		if(Meteor.user())
			$(".node#node-" + this.data._id).draggable
				grid: [ GRID_MULTIPLIER_X, GRID_MULTIPLIER_Y ] 
				stop: (event, ui) -> # fired when an item is dropped
					$("body").addClass "draft-mode"
					Session.set "draft-mode", "True"
					tut = Blaze.getData(ui.helper[0])
					$(".node#node-" + tut._id).addClass("draft-node")

					Meteor.call("moveTutorial", tut, ui.position.left / GRID_MULTIPLIER_X, ui.position.top / GRID_MULTIPLIER_Y)

					jsPlumb.repaintEverything()



	Accounts.ui.config
		passwordSignupFields: "USERNAME_ONLY"

	$ ->
		$(".login-shortcut").click ->
			$("#login-sign-in-link").click()



if Meteor.isServer

	#	port = process.env.PORT || 8080
	#	db = process.env.MONGO_URL 


	Meteor.publish "tutorials", () ->
		if(this.userId)
			return Tutorials.find {}
		else
			return Tutorials.find {'publishMode':'publish'}

	Meteor.publish "icons", () ->
		return Icons.find {}

	Meteor.publish "links", () ->
		return Links.find {} 

#	Meteor.publish "steps", () ->
#		return Steps.find {}

	Meteor.publish "courses", () ->
		if(this.userId)
			return Courses.find {}
		else
			return Courses.find {'publishMode':'publish'}

	Meteor.publish "weeks", () ->
		return Courses.find {}

Meteor.methods
	addTutorial: () ->
		# Make sure the user is logged in before inserting a task
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
			# This function is called when the new tutorial form is submitted

		title = "New Tutorial"
		description = "New Tutorial Description"
		x = 5
		y = 5
		Tutorials.insert
			title: title
			description: description
			publishMode: "unpublish"
			draft_x: x
			draft_y: y
			x: x
			y: y
			createdAt: new Date() # current time
			createdById: Meteor.userId()
			createdByUsername: Meteor.user().username
		return

	saveTutorialLocation: (t, action) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
			# This function is called when the new tutorial form is submitted
		if action == "save"
			Tutorials.update t._id,
				$set:
					x: t.draft_x
					y: t.draft_y
		else
			Tutorials.update t._id,
				$set:
					draft_x: t.x
					draft_y: t.y

	updateTutorial: (tut_id, title, publishMode) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
		Tutorials.update tut_id,
			$set:  
				title: title
				publishMode: publishMode
				updatedAt: new Date() # current time
				updatedById: Meteor.userId()
				updatedByUsername: Meteor.user().username

	moveTutorial: (tut, draft_x, draft_y) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
		Tutorials.update tut._id,
			$set:
				draft_x: draft_x
				draft_y: draft_y

	updateStep: (step_id, ordinal) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
		Steps.update step_id,
			$set:  
				ordinal: ordinal
				updatedAt: new Date() # current time

