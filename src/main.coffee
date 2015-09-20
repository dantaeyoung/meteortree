
Accounts.config({forbidClientAccountCreation: true})

if Meteor.isClient

	Template.body.helpers
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
