
Template.megavision.created = ->

	$(document).bind 'mousemove', (e) ->
		Session.set('mousePosition', {'x': e.pageX, 'y': e.pageY})

	cursoryglanceInterval = Meteor.setInterval(trackCursoryGlance, 100)

Template.megavision.destroyed = ->
	Meteor.clearInterval(cursoryglanceInterval)


Template.megavision.helpers
	version: ->
		return "v0.1"

	mousePositionFromDB: ->
		cursoryGlance = CursoryGlances.findOne({ userFingerprint: "dan" })
		return cursoryGlance

	cursoryGlances: ->
		return CursoryGlances.find({})

mousePositionsDiffered = (p1, p2) ->
	if typeof(p1) == 'undefined' or typeof(p2) == 'undefined'
		return true 
	if p1.x == p2.x and p1.y == p2.y
		return false
	else
		return true

trackCursoryGlance = () ->

	if mousePositionsDiffered(Session.get('prevMousePosition'), Session.get('mousePosition')) and Session.get('userFingerprint')

		Session.set('prevMousePosition', Session.get('mousePosition'))

		# there must be a better way to clean this up
		console.log Session.get('userFingerprint')
		cursoryGlance = CursoryGlances.findOne({ userFingerprint: Session.get('userFingerprint') })
		cursoryGlanceId = ''
		if typeof(cursoryGlance) == 'undefined'
			alert "we're adding new"
			console.log "$$$$$$$$$$$$$"
			console.log "$$$$$$$$$$$$$"
			console.log "$$$$$$$$$$$$$"
			console.log typeof(cursoryGlance) == 'undefined'
			console.log cursoryGlance
			console.log CursoryGlances.findOne({ userFingerprint: Session.get('userFingerprint') })
			CursoryGlances.insert
				userFingerprint: Session.get('userFingerprint')
				mousePosition: Session.get('mousePosition')
				updatedAt: new Date() # current time
		else
			console.log cursoryGlance
			CursoryGlances.update cursoryGlance._id ,
				$set:
					userFingerprint: Session.get('userFingerprint')
					mousePosition: Session.get('mousePosition')
					updatedAt: new Date() # current time

