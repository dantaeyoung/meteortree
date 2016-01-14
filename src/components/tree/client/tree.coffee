#########
# GRAPH #
#########
#
#

	Template.tree.events
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


	SkillTreeBezier = ->
		_super =  jsPlumb.Connectors.AbstractConnector.apply(this, arguments);

		this.type = "SkillTreeBezier"
		this._compute = (paintInfo) ->

			x1 = paintInfo.sx
			y1 = paintInfo.sy + 25
			x2 = paintInfo.tx
			y2 = paintInfo.ty + 25

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

	jsPlumb.Defaults.Connector = [ "SkillTreeBezier", { curviness: 35, cornerRadius: 30 } ]
	jsPlumb.Defaults.PaintStyle = { 
		strokeStyle: "gray", 
		lineWidth: 1, 
		dashstyle: '3 2' 
	}
	jsPlumb.Defaults.EndpointStyle = { radius: 0 }
	jsPlumb.Defaults.Anchor = [ "Left", "Right" ]

	Session.set "dep-mode", "False"
	Session.set "nodes-rendered", 0
	nodes_dep = new Deps.Dependency()

	endDepMode = (end_id) ->
		$("body").removeClass "dep-mode"
		$("#section-tree").unbind "mousemove"
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

	# this gets updated and passed into the minimap
	map = null
	containerWidth = $('#column-navtree').width()
	containerHeight = 0

	Template.node.helpers
		xpos: ->
			if(Meteor.user())
				this.draft_x * GRID_MULTIPLIER_X
			else
				this.x * GRID_MULTIPLIER_X
		ypos: ->
			if this.y * GRID_MULTIPLIER_Y > containerHeight + 80
				containerHeight = this.y * GRID_MULTIPLIER_Y + 80
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
		nodeIcon: ->
			icon_id = this.icon_id
			icon = s3Icons.findOne({ _id: icon_id })

			s3url = (id, name) ->
				return (BUCKET_URL + 'icons/images/' + id + '-' + name)

			if (icon)
				imgurl = s3url(icon._id, icon.original.name)
			else
				imgurl = "/" + DEFAULT_ICON
			return "<img src='" + imgurl + "'>"



	Template.node.events 

		"click": (event) ->

			# TODO: transform tooltip into right col

			tutid = this._id
			node = $("#node-" + tutid)
			tutorial = $(".tutorial")

			$('.node').not(node).removeClass "courseHighlight courseHover"

			if Session.get("dep-mode") is "True"
				endDepMode(this._id)
			else
				# not in week mode
				unless Session.get("week-mode") is "True"
					if !node.hasClass "courseHighlight"
						$('#column-content').fadeIn()
						tutorial.fadeOut(100, () ->
							tutorial.fadeIn(100);
						);
					else
						$('#column-content').fadeOut()

					node.toggleClass "courseHighlight"
					
				# viewing a week, only show nodes in that week
				else
					weekfrom = Session.get("week-mode-from")
					weeksnodes = Weeks.findOne(_id: weekfrom).nodes

					if node.hasClass 'weekmodeHighlight'
						$('#column-content').fadeIn()
						tutorial.fadeOut(100, () ->
							tutorial.fadeIn(100);
						);
					else
						$('#column-content').hide()
					
					'''
					if (tutid in weeksnodes)
						# $("#node-" + tutid).removeClass "courseHighlight"
						weeksnodes = _.without(weeksnodes, tutid)
					else
						# $("#node-" + tutid).addClass "courseHighlight"
						weeksnodes.push(tutid)
					Weeks.update weekfrom,
						$set:
							nodes: weeksnodes
					'''

		"click .change-dep": ->
			if(Meteor.user())

				# console.log this
				unless Session.get("dep-mode") is "True"
					$("body").addClass "dep-mode"
					Session.set "dep-mode", "True"
					Session.set "dep-from", this._id
					Session.set "mouseX", this.draft_x * GRID_MULTIPLIER_X
					Session.set "mouseY", this.draft_y * GRID_MULTIPLIER_Y
					$("#section-tree").bind "mousemove", (e) ->
						$("#section-tree").line Session.get('mouseX'),Session.get('mouseY'),e.offsetnX, e.offsetY, {id: 'depline'}
				else
					endDepMode(this._id)



	Template.node.rendered = ->

		Session.set("nodes-rendered", Session.get("nodes-rendered") + 1)

		Meteor.subscribe "tutorials"
		Meteor.subscribe "links"

		tuts = Tutorials.find {},
			sort:
				createdAt: -1
		tutcount = tuts.count()
		if (Session.get("nodes-rendered") == tutcount)
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


	drawLinks = (from_id) ->
		Meteor.subscribe "links"
		Meteor.subscribe "tutorials"

		tut1PublishMode = Tutorials.findOne({_id: from_id}).publishMode

		_.each Links.find({tutorial1: from_id}).fetch(), (d) ->
			tut2PublishMode = Tutorials.findOne({_id: d.tutorial2}).publishMode

			jsPlumb.setContainer("tree-links")
			jsPlumb.connect
				source: $('#node-' + d.tutorial1)
				target: $('#node-' + d.tutorial2)



	Template.tree.helpers nodes: ->
		Meteor.subscribe("tutorials")
		return Tutorials.find {},
			sort:
				createdAt: -1

	Template.tree.rendered = ->
		map = Minimap $('#column-navtree'), $('.node'), containerWidth, containerHeight
		map.create()
		Session.set 'Minimap', map

		# reference map from $
		$.fn.extend(
			minimap: () -> return map
		)
		
		this._rendered = true
		updateMap = () ->
			console.log('updating map. width:', $('#colum-navtree').width())
			if (containerHeight == 0)
				setTimeout(updateMap, 250)
			else
				map.update($('.node'), $('#column-navtree').width(), containerHeight)
		updateMap()
		$('#column-navtree').dragScroll({});

