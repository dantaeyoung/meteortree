container = null # set on render
scale = 0.11
mouse = {}
mousedown = false

clamp = (val, min, max) ->
	return Math.max(min, Math.min(val, max))

draw = () ->

	minimap = $('#minimap')
	bg = $('.minimap-bg')
	viewport = $('#minimap-viewport')

	bg.attr({
		height: scale * Session.get('containerHeight')
		width: scale * $('#column-navtree').width()
	})

	if container.width() > Session.get('containerWidth')
		minimap.width(scale * container.width())
		bg.width(scale * container.width())
	else
		minimap.width(scale * Session.get('containerWidth'))
		bg.width(scale * Session.get('containerWidth'))

	viewport.attr({
		width: scale * container.width() - 6,
		height: scale * container.height() - 6
	})

	viewport.attr({
		x: clamp(scale * container.scrollLeft(), 3, minimap.width() - (+viewport.attr('width')) - 3),
		y: clamp(scale * container.scrollTop(), 3, minimap.height() - (+viewport.attr('height')) - 3)
	})

dimAdd = (which, val) ->
	return dims[which] + val

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
			path += (0.5 * (x2 + x1)) + ' ' + y2 + ', '
			path += x2 + ' ' + y2

			return path

		return ''
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

	$('#minimap').attr({
		width: scale * Session.get('containerWidth')
		height: scale * Session.get('containerHeight')
	})

	draw()
	container.on('scroll', draw)
	$(window).on('mousemove resize', draw)
