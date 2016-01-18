container = null # set on render
scale = 0.11
mouse = {}
mousedown = false

draw = () ->
	if container.width() > Session.get('containerWidth')
		$('#minimap').width(scale * container.width())
	else
		$('#minimap').width(scale * Session.get('containerWidth'))

	$('#minimap-viewport').attr({
		x: scale * container.scrollLeft(),
		y: scale * container.scrollTop(),
		width: scale * container.width(),
		height: scale * container.height()
	})

Template.minimap.helpers
	nodes: ->
		Meteor.subscribe("tutorials")
		return Tutorials.find {},
			sort:
				createdAt: -1

	links: ->
		Meteor.subscribe('links')
		return Links.find({})
	
	link: () ->
		tut1 = Tutorials.findOne({
			_id: this.tutorial1
		})
		tut2 = Tutorials.findOne({
			_id: this.tutorial2
		})

		if ( tut1 && tut2 )

			x1 = tut1.x * GRID_MULTIPLIER_X * scale
			x2 = tut2.x * GRID_MULTIPLIER_X * scale
			y1 = tut1.y * GRID_MULTIPLIER_Y * scale
			y2 = tut2.y * GRID_MULTIPLIER_X * scale

			path = ''
			path += 'M' + x1 + ' ' + y1 + ' '
			path += 'C ' + (0.5 * (x2 + x1)) + ' ' + y1 + ', '
			path += (0.5 * (x2 + x1)) + ' ' + (0.5 * (y2 + y1)) + ', '
			path += x2 + ' ' + (0.5 * (y2 + y1))

			return path

		return ''


	height: scale * Session.get('containerHeight')
	width:  scale * $('#column-navtree').width()
	cx: () ->
		return scale * this.x * GRID_MULTIPLIER_X
	cy: () ->
		return scale * this.y * GRID_MULTIPLIER_Y

Template.minimap.events

	mousedown: (e) ->
		mousedown = true
		mouse.x = e.offsetX
		mouse.y = e.offsetY

	mousemove: (e) ->
		e.stopPropagation()

		if mousedown

			x = (e.offsetX - mouse.x) / scale
			y = (e.offsetY - mouse.y) / scale

			mouse.x = e.offsetX
			mouse.y = e.offsetY

			container.scrollLeft(container.scrollLeft() + x)
			container.scrollTop(container.scrollTop() + y)
			draw()
	mouseleave: -> 
		mousedown = false
	mouseup: -> 
		mousedown = false

Template.minimap.rendered = ->

	container = $('#column-navtree')

	$('#minimap')
		.width(scale * Session.get('containerWidth'))
		.height(scale * Session.get('containerHeight'))

	draw()
	container.on('scroll', draw)
	$(window).on('mousemove resize', draw)