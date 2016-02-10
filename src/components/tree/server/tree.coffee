Meteor.publish "tutorials", () ->
	if(this.userId)
		return Tutorials.find {}
	else
		return Tutorials.find {'publishMode':'publish'}

Meteor.publish "icons", () ->
	return Icons.find {}

Meteor.publish "links", () ->
	return Links.find {} 

Meteor.methods
	addTutorial: () ->
		# Make sure the user is logged in before inserting a task
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
			# This function is called when the new tutorial form is submitted

		title = "New Tutorial"
		description = "New Tutorial Description"
		x = 30 
		y = 25
		Tutorials.insert
			title: title
			description: description
			publishMode: "publish"
			draft_x: x
			draft_y: y
			x: x
			y: y
			createdAt: new Date() # current time
			createdById: Meteor.userId()
			createdByUsername: Meteor.user().username
		return

	saveTutorialLocation: (t, action) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
			# This function is called when the new tutorial form is submitted
		if action == "save"
			Tutorials.update t._id,
				$set:
					x: t.draft_x
					y: t.draft_y
		else
			Tutorials.update t._id,
				$set:
					draft_x: t.x
					draft_y: t.y

	moveTutorial: (tut, draft_x, draft_y) ->
		if !Meteor.userId()
			throw new (Meteor.Error)('not-authorized')
		Tutorials.update tut._id,
			$set:
				draft_x: draft_x
				draft_y: draft_y


