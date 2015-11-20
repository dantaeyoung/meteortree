
Template.megavision.created = ->

	$(document).bind 'mousemove', (e) ->
		Session.set('mousePosition', {'x': e.pageX, 'y': e.pageY})

	cursoryglanceInterval = Meteor.setInterval(trackCursoryglance, 1000)

Template.megavision.destroyed = ->
	Meteor.clearInterval(cursoryglanceInterval)


Template.megavision.helpers
	version: ->
		return "v0.1"

	mousePositionFromDB: ->
		cursoryGlance = CursoryGlancess.findOne({ userFingerprint: "dan" })
		return cursoryGlance


trackCursoryglance = () ->
	console.log("tracking")
	console.log Session.get('mousePosition')

	"""
	CursoryGlances.update {
		userFingerprint: "dan"
	}, {
		$set:
			userFingerprint: "dan"
			mousePosition: Session.get('mousePosition')
			updatedAt: new Date() # current time
		upsert: true
	}
	"""

