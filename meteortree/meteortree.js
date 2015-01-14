
Tutorials = new Mongo.Collection("tutorials");
Steps = new Mongo.Collection("steps");

if (Meteor.isClient) {
	// counter starts at 0
	Session.setDefault("counter", 0);

	Template.body.helpers({
		tutorials: function () {
			return Tutorials.find({}, {sort: {createdAt: -1}});
		},
		icons: function () {
			return Tutorials.find({}, {sort: {createdAt: -1}});
		}
	});

	Template.body.events({
		"submit .new-tutorial": function (event) {
			// This function is called when the new tutorial form is submitted

			var title = event.target.title.value;
			var x = event.target.x.value;
			var y = event.target.y.value;

			Tutorials.insert({
				title: title,
				x: x,
				y: y,
				createdAt: new Date() // current time
			});

			// Clear form
			event.target.title.value = "";

			// Prevent default form submit
			return false;
		}
	});

	Template.tutorial.helpers({
		steps: function () {
			return Steps.find({tutorial_id: this._id}, {sort: {ordinal: -1, createdAt: -1}});
		}
	});

	Template.tutorial.events({
		'click button.xplus': function () {
			Tutorials.update(this._id, {$set: {x: parseInt(this.x) + 1}});
		},
		'click button.xminus': function () {
			Tutorials.update(this._id, {$set: {x: parseInt(this.x) - 1}});
		},
		'click button.yplus': function () {
			Tutorials.update(this._id, {$set: {y: parseInt(this.y) + 1}});
		},
		'click button.yminus': function () {
			Tutorials.update(this._id, {$set: {y: parseInt(this.y) - 1}});
		},
		'click button.delete': function () {
			Tutorials.remove(this._id);
		}
	});

	Template.step.helpers({
		video_embedded: function() {
			return '<iframe width="420" height="315" src="'+this.video_url+
			'" frameborder="0" allowfullscreen></iframe>'
		}
	});

	Template.step.events({
		'submit .update-step': function () {
			var description = event.target.description.value;
			var video_url = event.target.video_url.value;
			var ordinal = event.target.ordinal.value;
			console.log(event);
			console.log(this);
			console.log(this._id);

			Steps.upsert(this._id, { $set: 
				 {
					tutorial_id: this.tutorial_id,
					description: description,
					video_url: video_url,
					ordinal: ordinal,
					createdAt: new Date() // current time
				}}
			);

			if("new" in this) {
				event.target.description.value = "";
				event.target.video_url.value = "";
			}

			return false;
		}
	});

	Template.icon.helpers({
		xpos: function() {
			return this.x * GRID_MULTIPLIER;
		}, 
		ypos: function() {
			return this.y * GRID_MULTIPLIER;
		}
	});

	Template.icon.rendered = function() {
		$( ".icon" ).draggable({ grid: [ GRID_MULTIPLIER, GRID_MULTIPLIER ],
			stop: function (event, ui) { // fired when an item is dropped
      		var tut = Blaze.getData(ui.helper[0]);

			Tutorials.update(tut._id, {$set: {x: ui.position.left / GRID_MULTIPLIER, y: ui.position.top / GRID_MULTIPLIER }});

			}
		});
	};



}

if (Meteor.isServer) {
	Meteor.startup(function () {
		// code to run on server at startup
	});
}
