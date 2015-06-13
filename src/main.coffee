
Accounts.config({forbidClientAccountCreation: true})

if Meteor.isClient

	Template.body.helpers
		loggedin: ->
			if(Meteor.user())
				return "logged-in"
			else
				return "not-logged-in"

	Accounts.ui.config
		passwordSignupFields: "USERNAME_ONLY"

	$ ->
		$(".login-shortcut").click ->
			$("#login-sign-in-link").click()





