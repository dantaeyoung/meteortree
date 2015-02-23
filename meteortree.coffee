Tutorials = new Mongo.Collection("tutorials")
Steps = new Mongo.Collection("steps")
Links = new Mongo.Collection("deps")
Courses = new Mongo.Collection("courses")
Weeks = new Mongo.Collection("weeks")
Icons = new FS.Collection("icons", {
  stores: [new FS.Store.FileSystem("icons")]
});

if Meteor.isClient
	
	window.Courses = Courses
	window.Weeks = Weeks
	Session.set "dep-mode", "False"
	nodes_dep = new Deps.Dependency()
	steps_dep = new Deps.Dependency()
	jsPlumb.setContainer($("#jsPlumbContainer"))
	jsPlumb.Defaults.Connector = [ "Bezier", { curviness: 40 } ]
	jsPlumb.Defaults.PaintStyle = { strokeStyle:"gray", lineWidth:1 }
	jsPlumb.Defaults.EndpointStyle = { radius:3, fillStyle:"gray" }
	jsPlumb.Defaults.Anchor = [ "Left", "Right" ]

	Template.body.helpers
		tutorials: ->
			if(Meteor.user())
				Tutorials.find {},
					sort:
						createdAt: -1
			else
				Tutorials.find  {},
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
					console.log t
					Tutorials.update t._id,
						$set:
							x: t.draft_x
							y: t.draft_y
				$("body").removeClass "draft-mode"
				$(".node").removeClass "draft-node"
				Session.set "draft-mode", "False"
		
		"click .discard-draft": ->
			if(Meteor.user())
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
				jsPlumb.repaintEverything()

		
		"submit .new-tutorial": (event) ->
			event.preventDefault()
			
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

			$(".tutorial").find(".edit-form").hide('slide', { 'direction': 'right'}, 300);
			title = event.target.title.value

			console.log $("#tutorial-" + tut_id + " form.update-tutorial :checkbox:checked").length > 0

			console.log $("#tutorial-" + tut_id + " input[name='publishMode']")
			console.log $("#tutorial-" + tut_id + " input[name='publishMode']").is(":checked")

			if $("#tutorial-" + tut_id + " form.update-tutorial :checkbox:checked").length > 0
				publishMode = "publish"
			else
				publishMode = "unpublish"


			console.log publishMode

			Tutorials.update tut_id,
				$set:  
					title: title
					publishMode: publishMode
					updatedAt: new Date() # current time
					updatedById: Meteor.userId()
					updatedByUsername: Meteor.user().username
			return false


	Template.tutorial.helpers
		steps: ->
			Steps.find
				tutorial_id: this._id
			,
				sort:
					ordinal: -1
		nodeIcon: ->
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
			$(".tutorial").find(".edit-form").hide('slide', { 'direction': 'right'}, 300);



	Template.tutorial.rendered = ->	
		if(!this._rendered)
			this._rendered = true;

			$('.lazyYT').lazyYT()
			if(Meteor.user())
				$( ".steps.sortable" ).sortable
					handle: ".sorthandle"
					start: (event, ui ) ->
						$(this).addClass("sorting");
					stop: (event, ui ) ->
						$(this).removeClass("sorting");
						$(this).children(".step").each (i) ->
							Steps.update $(this).attr("id"),
								$set:  
									ordinal: i * 10
									updatedAt: new Date() # current time
								(error) -> 
									console.log error
			

		
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
		$(".step").find(".edit-form").hide('slide', { 'direction': 'right'}, 300);
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
		if(Meteor.user())
			Tutorials.find {},
				sort:
					createdAt: -1
		else
			Tutorials.find {'publishMode':'publish'},
				sort:
					createdAt: -1

	Template.sectiontree.rendered = ->
		if(!this._rendered)
			this._rendered = true;
			#template onload


	Template.sectioncourses.helpers
		courses: ->
			if(Meteor.user())
				Courses.find {},
					sort:
						createdAt: -1
			else
				Courses.find {'publishMode':'publish'},
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
#				$(".node#" + this._id).addClass("draft-node")


	Template.body.events "click .button": ->
		targetForm = $(event.target).closest(".step, .tutorial").find(".edit-form").first()
			.toggle('slide', { 'direction': 'right'}, 300)
				

	Template.node.events "click": (event) ->
		tutid = this._id
		unless Session.get("week-mode") is "True" 
			console.log this
			$(".tutorial").fadeOut(50);
			console.log "#tutorial-" + tutid
			$("#tutorial-" + tutid).fadeIn(50);
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
					
					drawLinks tut1_id

	
	drawLinks = (from_id) ->

		tut1PublishMode = Tutorials.findOne({_id: from_id}).publishMode

		_.each Links.find({tutorial1: from_id}).fetch(), (d) ->
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

		drawLinks this.data._id

		if(Meteor.user())
			$(".node#node-" + this.data._id).draggable
				grid: [ GRID_MULTIPLIER_X, GRID_MULTIPLIER_Y ] 
				stop: (event, ui) -> # fired when an item is dropped
					$("body").addClass "draft-mode"
					Session.set "draft-mode", "True"
					tut = Blaze.getData(ui.helper[0])
					$(".node#node-" + tut._id).addClass("draft-node")

					Tutorials.update tut._id,
						$set:
							draft_x: ui.position.left / GRID_MULTIPLIER_X
							draft_y: ui.position.top / GRID_MULTIPLIER_Y
				drag: (event, ui) ->
					jsPlumb.repaintEverything()


	Accounts.ui.config
		passwordSignupFields: "USERNAME_ONLY"

	$ ->
		$(".login-shortcut").click ->
			$("#login-sign-in-link").click()


if Meteor.isServer
	Meteor.startup ->
		
