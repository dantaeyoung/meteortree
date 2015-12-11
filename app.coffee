Accounts.config({forbidClientAccountCreation: true})

if Meteor.isClient

	Template.mainLayout.events
		"click .modal-shadow": (e) ->
			$('[modal-target]').fadeOut()
			$('.modal-shadow').fadeOut();

	Template.mainLayout.helpers
		loginStatus: ->
			if(Meteor.user())
				return "logged-in"
			else
				return "not-logged-in"

	Accounts.ui.config
		passwordSignupFields: "USERNAME_ONLY"

	$ ->
		$("#login-shortcut").click ->
			if(Meteor.user())
				Meteor.logout()
			else
				$("#login-sign-in-link").click()

	Meteor.startup ->
		new Fingerprint2().get (result) ->
			Session.set("userFingerprint", result)

	Template.adminContainer.events
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

		

Router.configure
	layoutTemplate: 'mainLayout'

Router.route '/tutorial/:_tutid', ->
	this.render 'tutorial',
		to: 'tutorial'
		data: ->
			return Tutorials.findOne({_id: this.params._tutid});

