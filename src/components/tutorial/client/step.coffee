steps_dep = new Deps.Dependency()


Template.stepList.helpers
	steps: ->
		# Meteor.subscribe "steps"
		Steps.find { tutorial_id: this._id },
			sort:
				ordinal: 1
	allRendered: ->
		Meteor.defer () ->
			# console.log ("all steps rendered!")
			$('.lazyYT').lazyYT()
		return


Template.step.helpers
	editMode: ->
		return Session.get('editMode')
	video_embedded: ->
		if this.video_url
			parseUrl = this.video_url.match(/(http|https):\/\/(?:www.)?(?:(vimeo).com\/(.*)|(youtube).com\/watch\?v=(.*?)$)/)
			if parseUrl
				if parseUrl[2] || parseUrl[3]
					vimeoID = parseUrl[3]
					embedUrl = '//player.vimeo.com/video/' + vimeoID
					return '<div class="lazyYT" data-vimeo-id="' + vimeoID + '"></div>'
				else
					youtubeID = parseUrl[5]
					embedUrl = '//www.youtube.com/embed/' + youtubeID
					return '<div class="lazyYT" data-youtube-id="' + youtubeID + '"></div>'

	is_step_type_checked: (step_type) ->
		if this.step_type == step_type
			return "checked"

	is_video: ->
		return this.step_type == "step_video"

	is_markdown: ->
		return this.step_type == "step_markdown"

Deps.autorun ->
	steps_dep.depend()
	$('.lazyYT').lazyYT()

Template.step.events
    "click button.delete": ->
        r = confirm("Delete this step? This cannot be undone.")
        if r == true
            Steps.remove this._id

    "click .step .button": (event, target) ->
        targetForm = $(event.target).closest(".step").find(".step-edit").first()
            .toggle('slide', { 'direction': 'right'}, 300)

    "submit .update-step": (event) ->
        event.preventDefault();

        description_text = event.target.description_text.value
        title_text = event.target.title_text.value
        video_url = event.target.video_url.value
        step_type = event.target.step_type.value
        markdown_text = event.target.markdown_text.value

        Steps.upsert this._id,
            $set:
                tutorial_id: this.tutorial_id
                step_type: step_type
                markdown_text: markdown_text
                description_text: description_text
                title_text: title_text
                video_url: video_url
                ordinal: this.ordinal || 99999
                updatedAt: new Date() # current time
        if "new" in this
            event.target.title_text.value = ""
            event.target.description_text.value = ""
            event.target.video_url.value = ""
        steps_dep.changed()
        console.log "update-step"
        return false

    "change [name='step_type']": (e) ->
        value = e.target.value;
        container = $(e.target).closest('.step-edit')
        match = {
            'step_video': 'video_url_container',
            'step_markdown': 'markdown_text_container'
        }

        for key, selector of match
            if ( key == value )
                container.find('.' + selector).show()
            else
                container.find('.' + selector).hide()

Template.step.rendered = ->
	button = this.find('.button');

