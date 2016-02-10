Template.mainLayout.helpers
	tutorials: ->
		Meteor.subscribe('tutorials')
		return Tutorials.find {},
			sort:
				createdAt: -1

EditableText.userCanEdit = (doc,Collection) ->
	if Meteor.userId()
		return true
	return false


Template.tutorial.events

	"click .tutorial-delete button.delete": ->
		r = confirm("Delete this tutorial? This cannot be undone.")
		if r == true
			Tutorials.remove this._id

	"change .iconInput": (event, target) ->
		thistut = this._id
		FS.Utility.eachFile event, (file) ->
			s3Icons.insert file, (err, fileObj) ->
				Tutorials.update thistut,
					$set:
						icon_id: fileObj._id

	"change .previewInput": (e, target) ->
		thistut = this._id
		FS.Utility.eachFile event, (file) ->
			s3Icons.insert file, (err, fileObj) ->
				Tutorials.update thistut,
					$set:
						preview_id: fileObj._id

	"change .fileInput": (event, target) ->
		console.log('changing file', event, target);
		thistut = this._id
		FS.Utility.eachFile event, (file) ->

			fileType = file.name.split('.')
			fileType = fileType[fileType.length - 1]

			if ALLOWED_FILE_TYPES.indexOf(fileType) > -1
				s3Files.insert file, (err, fileObj) ->
					Tutorials.update thistut,
						$push:
							file_ids: fileObj._id
			else
				alert 'Only the following file types:\n-' + ALLOWED_FILE_TYPES.join('\n-') + '\nare allowed.' 

	"click .tutorial-tab.slide": (e) ->
		tab = $(e.target)
		content = $('#column-content')
		anim = (start, end) ->
			
			diff = 0
			factor = 5

			content.css(
				transform: 'translateX(' + start + '%)'
			)
			
			if (end > start)
				diff = factor
				if (start + diff > end)
					diff = end - start
			
			if (end < start)
				diff = -factor
				if (start + diff < end)
					diff = end - start
			
			if (diff != 0)
				requestAnimationFrame(anim.bind(null, start + diff, end))

		if ( tab.hasClass('open') )
			anim(90, 0)
		else
			anim(0, 90)

		$('body').toggleClass('node-content-hidden')
		tab.toggleClass('open')

	"click .tutorial-tab.edit": (e) ->
		Session.set('editMode', !Session.get('editMode'))

	"click .view-trail": (e) ->
		e.preventDefault()
		# see src/components/course/client/course.coffee
		$this = $(e.target)
		course_id = $this.attr('data-trail-id')
		
		$('.node').removeClass('courseHover')

		if ( !$this.hasClass('showing') )

			_.each $("#course-" + course_id).find(".week"), (d) ->
				_.each Blaze.getData(d).nodes, (n) ->
					$("#node-" + n).addClass "courseHover" 

		$this.siblings().removeClass('showing')
		$this.toggleClass('showing')

	"click .delete-file": (e) ->
		e.preventDefault()
		file_id = this._id
		file = s3Files.findOne({ _id: file_id })

		thistut = $(e.target).closest('.tutorial').attr('id').replace('tutorial-', '')
		Tutorials.update thistut,
			$pull: {
				file_ids: file_id
			}

		file.remove(() ->
			s3Files.remove file_id
		)

	"click .delete-img-preview": (e) ->
		e.preventDefault();
		preview_id = $(e.target).closest('.img-preview').attr('data-id')
		preview = s3Icons.findOne({ _id: preview_id })
		
		preview.remove(() ->
			s3Icons.remove preview_id
		)

		thistut = this._id
		Tutorials.update thistut,
			$unset:
				preview_id: null


	"change .update-tutorial": (event, ui) ->
		event.preventDefault();

		window.windowthis = this
		window.windowevent = event
		window.windowui = ui

		tut_id = this._id
		tut_id ?= ui._id

		title = ui.title

		if $("#tutorial-" + tut_id + " form.update-tutorial :checkbox:checked").length > 0
			publishMode = "publish"
		else
			publishMode = "unpublish"

		Meteor.call("updateTutorial", tut_id, title, publishMode)
		# return false


Template.tutorial.onRendered = ->
	$('.lazyYT').lazyYT()
	console.log("tutorial rendered")
	if (Meteor.user())
		$( ".steps.sortable" ).sortable
			handle: ".sorthandle"
			start: (event, ui ) ->
				$(this).addClass("sorting");
			stop: (event, ui ) ->
				$(this).removeClass("sorting");
				$(this).children(".step").each (i, d) ->
					Meteor.call("updateStep", Blaze.getData(d)._id, i * 10)


Template.tutorial.helpers

	editMode: ->
		return Session.get('editMode')

	sectionClass: ->
		if Session.get('editMode') == true
			return 'edit-mode'
		else
			return ''

	nodeIcon: ->
		icon_id = this.icon_id
		icon = s3Icons.findOne({ _id: icon_id })

		s3url = (id, name) ->
			return (BUCKET_URL + 'icons/images/' + id + '-' + name)

		if (icon)
			return s3url(icon._id, icon.original.name)
		return DEFAULT_ICON
	nodeUrl: ->
		if this.slug
			return "/tutorial/" + this.slug
		else 
			return "/tutorial/" + this._id 

	previewImg: ->
		preview_id = this.preview_id
		preview = s3Icons.findOne({ _id: preview_id })

		s3url = (id, name) ->
			return (BUCKET_URL + 'icons/images/' + id + '-' + name)

		url = if preview then s3url(preview._id, preview.original.name) else ''
		return url;

	trails: ->
		Meteor.subscribe('courses')
		Meteor.subscribe('weeks')

		weeksOfTutorial = Weeks.find( { "nodes": this._id } ).fetch()
		courseIdsOfTutorial = _.uniq(_.pluck(weeksOfTutorial, 'course_id'))
		idx = 0
		coursesOfTutorial = _.map courseIdsOfTutorial, (courseId) ->
			theCourse = Courses.findOne({ _id: courseId })
			theCourse.first = (idx == 0)
			idx++
			return theCourse
		return coursesOfTutorial

	files: ->
		# TODO: for better async handling, should file_ids be published server-side?
		file_ids = this.file_ids || []
			
		idx = 0
		getFile = (id) ->
			theFile = s3Files.findOne({ _id: id })
			if theFile
				theFile.first = idx == 0
			idx++
			return theFile

		files = _.compact(_.map(file_ids, getFile))

		return files



	publishMode: ->
		if this.publishMode == "publish"
			return "publish"
		else
			return "unpublish"
	publishChecked: ->
		if this.publishMode == "publish"
			return "checked"
		else
			return ""



Template.tutorialComments.helpers
	fullUrl: ->
		return window.location.protocol + "//" + window.location.host + this.tuturl
	
