
Template.megavision.created = ->

	$(document).bind 'mousemove', (e) ->
		Session.set('mousePosition', {
			'x': e.pageX, 
			'y': e.pageY
		})

	updateTimeInterval = Meteor.setInterval(updateTime, 5000)
	cursoryglanceInterval = Meteor.setInterval(trackCursoryGlance, 100)

Template.megavision.destroyed = ->
	Meteor.clearInterval(cursoryglanceInterval)
	Meteor.clearInterval(updateTimeInterval)


Template.megavision.helpers
	megavisionActive: ->
		return Session.get('megavisionActive')
	version: ->
		return "v0.1"

	mousePositionFromDB: ->
		cursoryGlance = CursoryGlances.findOne({ userFingerprint: "dan" })
		return cursoryGlance

	cursoryGlances: ->
		return CursoryGlances.find({})

secondsSince = (d) ->
		# TODO: date.now() dooesn't change
		return (Session.get("currentTime") - d) / 1000


Template.cursoryglance.helpers
	ss :->
		return secondsSince(Template.currentData().updatedAt)

	decayOpacity: ->
		ss = secondsSince(Template.currentData().updatedAt)
		return Math.pow(0.99, ss) + 0.1
	#return Math.sqrt(1/((ss+1)^0.2)) #TODO: make better


mousePositionsDiffered = (p1, p2) ->
	if typeof(p1) == 'undefined' or typeof(p2) == 'undefined'
		return true 
	if p1.x == p2.x and p1.y == p2.y
		return false
	else
		return true

updateTime = () ->
	Session.set("currentTime", Date.now())

trackCursoryGlance = () ->

	if Session.get('megavisionActive') and mousePositionsDiffered(Session.get('prevMousePosition'), Session.get('mousePosition')) and Session.get('userFingerprint')

		Session.set('prevMousePosition', Session.get('mousePosition'))

		# there must be a better way to clean this up
		# console.log Session.get('userFingerprint')
		cursoryGlance = CursoryGlances.findOne({ 
			userFingerprint: Session.get('userFingerprint') 
		})
		cursoryGlanceId = ''
		
		if typeof(cursoryGlance) == 'undefined'

			CursoryGlances.insert
				userFingerprint: Session.get('userFingerprint')
				mousePosition: Session.get('mousePosition')
				updatedAt: new Date() # current time
		else
			CursoryGlances.update cursoryGlance._id ,
				$set:
					userFingerprint: Session.get('userFingerprint')
					mousePosition: Session.get('mousePosition')
					updatedAt: new Date() # current time

