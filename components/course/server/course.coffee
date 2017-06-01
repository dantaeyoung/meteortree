Meteor.publish "weeks", () ->
	return Courses.find {}


Meteor.publish "courses", () ->
	if(this.userId)
		return Courses.find {}
	else
		return Courses.find {'publishMode':'publish'}

#	Meteor.publish "steps", () ->
#		return Steps.find {}


