from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
	pass

@app.route('/login', methods=['GET', 'POST'])
def login():
	    if request.method == 'POST':
			        do_the_login()
					    else:
							        show_the_login_form()


@app.route("/message/<message>")
def message(message):
	return "Your message was %s" % message

@app.route('/user/<username>')
def profile(username):
	pass

with app.test_request_context():
	print url_for('index')
	print url_for('login')
	print url_for('login', next='/')
	print url_for('profile', username='John Doe')


if __name__ == "__main__":
	app.debug = True
	app.run()

