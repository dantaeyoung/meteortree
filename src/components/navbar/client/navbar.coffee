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