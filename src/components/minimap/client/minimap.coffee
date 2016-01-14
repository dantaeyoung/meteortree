Minimap = ($container, nodes, width, height) ->

	scale = 0.12 # scale relative to window
	w = 4 # width of minimap node
	h = 4 # height of minimap node

	mouseDown = false
	mouseX = null
	mouseY = null

	canvas = document.createElement 'canvas'
	canvas.id = 'minimap'
	canvas.width = width * scale
	canvas.height = height * scale

	context = canvas.getContext '2d'

	draw = () ->

		context.fillStyle = '#fff'
		context.fillRect 0, 0, canvas.width, canvas.height
		
		xs = $container.scrollLeft() * scale
		ys = $container.scrollTop() * scale
		ws = $container.width() * scale
		hs = $container.height() * scale
		
		context.fillStyle = '#eaeaea';
		context.setLineDash [2, 2]
		context.beginPath()
		context.moveTo xs, ys
		context.lineTo xs + ws, ys
		context.lineTo xs + ws, ys + hs
		context.lineTo xs, ys + hs
		context.lineTo xs, ys
		context.fill()
		context.stroke()

		context.fillStyle = '#333'

		nodes.each(() ->
			x = scale * parseInt getComputedStyle(this).left
			y = scale * parseInt getComputedStyle(this).top
			context.fillRect x, y, w, h
		)

	draw()
	window.addEventListener('mousemove', draw);
	window.addEventListener('resize', draw);
	$container.on('scroll', draw);

	mouse = {}

	mousemove = (e) ->
		e.stopPropagation()

		if mouseDown

			x = (e.layerX - mouse.x) / scale
			y = (e.layerY - mouse.y) / scale

			mouse.x = e.layerX
			mouse.y = e.layerY

			$container.scrollLeft($container.scrollLeft() + x)
			$container.scrollTop($container.scrollTop() + y)
			draw()

	canvas.addEventListener('mousedown', (e) -> 
		mouseDown = true
		mouse.x = e.layerX
		mouse.y = e.layerY
	)

	canvas.addEventListener('mouseleave', () -> mouseDown = false)
	canvas.addEventListener('mouseup', () -> mouseDown = false)
	canvas.addEventListener('mousemove', mousemove)

	output = {
		create: () ->
			$container.append canvas
		
		update: (newNodes, width, height) ->
			nodes = newNodes
			canvas.width = width * scale
			canvas.height = height * scale
			draw()
	}

	return output

window.Minimap = Minimap