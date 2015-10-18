offOpacity = 0.6

styles = '
#minimap {
	border: 3px solid red;
	position: fixed;
	bottom: 25px;
	left: 15px;
	opacity: ' + offOpacity + ';
	transition: 0.2s opacity;
	z-index: 9999
} 
#minimap:active,
#minimap:hover {
	opacity: 1;
}
'

stylesheet = document.createElement 'style'
stylesheetId = 'minimap-stylesheet'
stylesheet.id = stylesheetId
stylesheet.innerHTML = styles

Minimap = ($container, nodes, width, height) ->

	scale = 0.15

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
		context.fillRect 0, 0, width, height
		
		x = $container.scrollLeft() * scale
		y = $container.scrollTop() * scale
		w = $container.width() * scale
		h = $container.height() * scale
		
		context.fillStyle = '#eaeaea';
		context.setLineDash [2, 2]
		context.beginPath()
		context.moveTo x, y
		context.lineTo x + w, y
		context.lineTo x + w, y + h
		context.lineTo x, y + h
		context.lineTo x, y
		context.fill()
		context.stroke()

		context.fillStyle = '#333'

		nodes.each(() ->
			x = scale * parseInt getComputedStyle(this).left
			y = scale * parseInt getComputedStyle(this).top
			w = 5
			h = 5
			context.fillRect x, y, w, h
		)

	draw()
	window.addEventListener('mousemove', draw);
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

	return {
		create: () -> 
			if !document.getElementById stylesheetId
				document.head.appendChild stylesheet
			$container.append canvas
	}

window.Minimap = Minimap