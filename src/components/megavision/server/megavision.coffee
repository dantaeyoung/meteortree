Meteor.methods

	debugRemoveAllCursoryGlances: () ->
		CursoryGlances.remove({})

	"""
	upsertCursoryGlance: (userFingerprint, mousePosition) ->
		Steps.upsert
			userFingerprint: userFingerprint
			$set:  
				userFingerprint: userFingerprint
				mousePosition: mousePosition
				updatedAt: new Date() # current time
	"""

