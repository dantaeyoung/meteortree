
Template.megavision.created = ->

	$(document).bind 'mousemove', (e) ->
		Session.set('mousePosition', {'x': e.pageX, 'y': e.pageY})

	cursoryglanceInterval = Meteor.setInterval(trackCursoryglance, 100)

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

sameMousePositions = (p1, p2) ->
	if typeof(p1) == 'undefined' or typeof(p2) == 'undefined'
		return false
	if p1.x == p2.x and p1.y == p2.y
		return true
	else
		return false

trackCursoryglance = () ->

	if not sameMousePositions(Session.get('prevMousePosition'), Session.get('mousePosition') and typeof(Session.get('userFingerprint')) != "undefined")

		Session.set('prevMousePosition', Session.get('mousePosition'))

		userFingerprint = Session.get('userFingerprint')
		# there must be a better way to clean this up
		cursoryGlance = CursoryGlances.findOne({ userFingerprint: userFingerprint })
		cursoryGlanceId = ''
		if typeof(cursoryGlance) == 'undefined'
			CursoryGlances.insert
				userFingerprint: userFingerprint
				mousePosition: Session.get('mousePosition')
				updatedAt: new Date() # current time
		else
			console.log cursoryGlance
			CursoryGlances.update cursoryGlance['_id'],
				$set:
					userFingerprint: userFingerprint
					mousePosition: Session.get('mousePosition')
					updatedAt: new Date() # current time

