
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
		cursoryGlance = CursoryGlances.findOne({ userFingerprint: "scott" })
		return cursoryGlance

	cursoryGlances: ->
		return CursoryGlances.find({})


trackCursoryglance = () ->
	console.log("tracking")
	console.log Session.get('mousePosition')

	# there must be a better way to clean this up
	cursoryGlance = CursoryGlances.findOne({ userFingerprint: "scott" })
	cursoryGlanceId = ''
	if typeof(cursoryGlance) == 'undefined'
		CursoryGlances.insert
			userFingerprint: "scott"
			mousePosition: Session.get('mousePosition')
			updatedAt: new Date() # current time
	else
		console.log cursoryGlance
		CursoryGlances.update cursoryGlance['_id'],
			$set:
				userFingerprint: "scott"
				mousePosition: Session.get('mousePosition')
				updatedAt: new Date() # current time

