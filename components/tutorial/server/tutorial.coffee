EditableText.userCanEdit = (doc,Collection) ->
    if Meteor.userId()
        return true
    else 
        return false
    return this.context.user_id == Meteor.userId()

Meteor.methods

	publishTutorial: (tut_id, doPublish) ->
		if doPublish == true
			Tutorials.update tut_id,
				$set:  
					publishMode: "publish"
		else
			Tutorials.update tut_id,
				$set:  
					publishMode: "unpublish"

	updateTutorial: (tut_id, title, publishMode) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
		Tutorials.update tut_id,
			$set:  
				title: title
				publishMode: publishMode
				updatedAt: new Date() # current time
				updatedById: Meteor.userId()
				updatedByUsername: Meteor.user().username

	updateStep: (step_id, ordinal) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
		Steps.update step_id,
			$set:  
				ordinal: ordinal
				updatedAt: new Date() # current time

