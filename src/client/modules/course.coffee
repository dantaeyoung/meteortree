	Template.sectioncourses.helpers
		courses: ->
			Meteor.subscribe("courses")
			return Courses.find {},
				sort:
					createdAt: -1

	Template.sectioncourses.events 

		"submit form.new-course": ->
			event.preventDefault()
			Courses.insert
				title: 'course title'
				publishMode: "unpublish"
				createdAt: new Date() # current time
				createdById: Meteor.userId()
				createdByUsername: Meteor.user().username
				# Clear form

	Template.course.events
		"click .add-week-button": (event) ->
			event.preventDefault()

			Weeks.insert
				title: "new week"
				ordinal: 99999
				nodes: []
				course_id:  this._id
				createdAt: new Date() # current time

		"click .delete-course-button": (event) ->
			r = confirm("Delete this course? This cannot be undone.")
			if r == true 
				Courses.remove this._id

		"mouseover .course-title": (event) ->
			$(".courseHighlight").removeClass("courseHighlight");
			$("#course-" + this._id).addClass("courseHighlight");
			_.each $("#course-" + this._id).find(".week"), (d) ->
				_.each Blaze.getData(d).nodes, (n) ->
					$("#node-" + n).addClass "courseHighlight" 

		"mouseout .course-title": (event) ->
			$(".courseHighlight").removeClass("courseHighlight");


		"mouseover .week": (event) ->
			$(".weekHighlight").removeClass("weekHighlight");
			$("#week-" + this._id).addClass("weekHighlight");
			unless Session.get("week-mode") is "True" 
				console.log this
				_.each this.nodes, (n) ->
					$("#node-" + n).addClass "weekmodeHighlight" 

		"mouseout .week": (event) ->
			$(".weekHighlight").removeClass("weekHighlight");
			unless Session.get("week-mode") is "True" 
				$(".weekmodeHighlight").removeClass "weekmodeHighlight"

		"click .week": (event) ->
			if(Meteor.user())
				if Session.get("week-mode-from") == this._id
					Session.set "week-mode", "False" 
					Session.set "week-mode-from", ""
					$(".weekfrom").removeClass("weekfrom")
					$("body").removeClass "week-mode"
				else
					Session.set "week-mode", "True" 
					Session.set "week-mode-from", this._id

					$(".weekmodeHighlight").removeClass "weekmodeHighlight"
					$(".weekfrom").removeClass("weekfrom")

					$("body").addClass "week-mode"
					$(event.target).addClass("weekfrom")

					_.each this.nodes, (n) ->
						$("#node-" + n).addClass "weekmodeHighlight" 

		"click .publishMode": (event) ->
			if this.publishMode == "publish"
				Courses.update this._id,
					$set:  
						publishMode: "unpublish"
						updatedAt: new Date() # current time
			else
				Courses.update this._id,
					$set:  
						publishMode: "publish"
						updatedAt: new Date() # current time



	Template.week.events
		"click .week .delete": (event) ->
			r = confirm("Delete this week? This cannot be undone.")
			if r == true 
				Weeks.remove this._id


	Template.course.helpers
		weeks: ->
			Meteor.subscribe "weeks"
			return Weeks.find {course_id: this._id},
				sort:
					ordinal: 1
		publishModeIcon: ->
			if this.publishMode == "publish"
				return '<i class="fa fa-eye publish"></i>'
			else
				return '<i class="fa fa-eye-slash unpublish"></i>'


	Template.course.rendered = ->
		if(Meteor.user())
			$( ".weeks.sortable" ).sortable
				handle: ".sorthandle"
				start: (event, ui ) ->
					$(this).addClass("sorting");
				stop: (event, ui ) ->
					$(this).removeClass("sorting");
					$(this).children(".week").each (i, d) ->
						Weeks.update Blaze.getData(d)._id,
							$set:  
								ordinal: i * 10
								updatedAt: new Date() # current time
							(error) -> 
								console.log error
		


