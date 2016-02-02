Template.navbar.events
	"click [data-modal]": (e) ->
		modal = $('[modal-target="' + e.target.getAttribute('data-modal') + '"')
		modalShadow = $('.modal-shadow')
		if ( modal.is(':visible') )
			modal.fadeOut()
			modalShadow.fadeOut()
		else
			modal.fadeIn()
			modalShadow.fadeIn()

	"click .modal-close": (e) ->
		$('[modal-target]').fadeOut()
		$('.modal-shadow').fadeOut()

	"click .login-link-text": (e) ->
		e.preventDefault()
		buttons = $(e.target).closest('#login-buttons')
		loginInputs = $('#login-dropdown-list')
		if ( buttons.hasClass('showing') )
			loginInputs.hide()
		else
			loginInputs.show()
		buttons.toggleClass('showing')

Template.settings.helpers
	megavisionOn: ->
		return (if Session.get('megavisionActive') then 'checked' else '')
	megavisionOff: ->
		return (if Session.get('megavisionActive') then '' else 'checked')

Template.settings.events
	'change [name="megavision-toggle"]': (e) ->
		val = if e.target.id == 'megavision-toggle-on' then true else false
		Session.set('megavisionActive', val)

Template.sectioncourses.helpers
	courses: ->
		Meteor.subscribe("courses")
		return Courses.find {},
			sort:
				createdAt: -1

Template.sectioncourses.events 

	"click .button": (e) ->
		$this = $(e.target)
		if !$this.hasClass('showing')
			$this.next().show().css({
				left: e.target.getBoundingClientRect().left,
				top: e.target.getBoundingClientRect().bottom - 1	
			})
		else
			$this.next().hide()
		$this.toggleClass('showing')

	"submit form.new-course": ->
		event.preventDefault()
		Courses.insert
			title: 'course title'
			publishMode: "unpublish"
			createdAt: new Date() # current time
			createdById: Meteor.userId()
			createdByUsername: Meteor.user().username
			# Clear form