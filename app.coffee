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

Router.configure
	layoutTemplate: 'mainLayout'

Router.route '/tutorial/:slug', ->
	this.render 'tutorial',
		#fastRender: true
		to: 'tutorial'
		data: ->
			tut = Tutorials.findOne({slug: this.params.slug})
			if tut 
				return tut
			return Tutorials.findOne({_id: this.params.slug}) #using id as fallback; sometime in the future  this could be removed

