# all the imports
from flask import Flask, request, session, g, redirect, url_for, abort, render_template, flash
from flask.ext import restful
from flask.ext.sqlalchemy import SQLAlchemy
from contextlib import closing

app = Flask(__name__)
api = restful.Api(app)

DATABASE = '/tmp/flaskr.db'
DEBUG = True
SECRET_KEY = 'development key'
USERNAME = 'admin'
PASSWORD = 'default'

app.config.from_object(__name__)
app.config.from_envvar('FLASKR_SETTINGS', silent=True)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + DATABASE

db = SQLAlchemy(app)


class Tutorial(db.Model):
	id = db.Column(db.Integer, primary_key=True)
	title = db.Column(db.String(80))
	publish = db.Column(db.String(20))
	iconPath = db.Column(db.String(80))
	x = db.Column(db.Integer, nullable=False)
	y = db.Column(db.Integer, nullable=False)

	def __init__(self, title, x, y):
		self.title = title
		self.x = x
		self.y = y

	def __repr__(self):
		return '<Tutorial %r>' % self.title

	def as_json(self):
		return {k:v for (k, v) in self.__dict__.items() if not k.startswith('_')}


class Dependency(db.Model):
	lower_id = db.Column(db.Integer, db.ForeignKey('tutorial.id'), primary_key=True)
	higher_id = db.Column(db.Integer, db.ForeignKey('tutorial.id'), primary_key=True)
	lower_tutorial = db.relationship(Tutorial, primaryjoin=lower_id==Tutorial.id, backref='lower_edges')
	higher_tutorial = db.relationship(Tutorial, primaryjoin=higher_id==Tutorial.id, backref='higher_edges')

	def __init__(self, t1, t2):
		if t1.id < t2.id:
			self.lower_tutorial = t1
			self.higher_tutorial = t2
		else:
			self.lower_tutorial = t2
			self.higher_tutorial = t1

def init_db():
	db.create_all()

@app.route('/login', methods=['GET', 'POST'])
def login():
	print(request.values)
	error = None
	if request.method == 'POST':
		if request.form['username'] != app.config['USERNAME']:
			error = 'Invalid username'
		elif request.form['password'] != app.config['PASSWORD']:
			error = 'Invalid password'
		else:
			session['logged_in'] = True
			flash('You were logged in')
			return redirect(url_for('show_tutorials'))
	return render_template('login.html', error=error)

@app.route('/logout')
def logout():
	session.pop('logged_in', None)
	flash('You were logged out')
	return redirect(url_for('show_tutorials'))

@app.route('/')
def root():
	return show_tutorials()

@app.route('/')
def show_tutorials():
	tutorials = Tutorial.query.all()
	return render_template('show_tutorials.html', tutorials=tutorials)

@app.route('/add', methods=['POST'])
def add_tutorial():
	if not session.get('logged_in'):
		abort(401)

	db.session.add(Tutorial(request.form['title'], 4, 5))
	db.session.commit()
	flash('New tutorial was successfully posted')
	return redirect(url_for('show_tutorials'))
	

@app.route('/delete/<tutorial_id>')
def delete_tutorial(tutorial_id):
	if not session.get('logged_in'):
		abort(401)
	Tutorial.query.get(tutorial_id).delete()
	db.session.commit()

	flash('Entry was succesfully removed')
	return redirect(url_for('show_tutorials'))

@app.route('/tutorial/<tutorial_id>')
def show_tutorial(tutorial_id):
	tutorial = Tutorial.query.get(tutorial_id)
	return render_template('show_tutorial.html', tutorial=tutorial)




class TutorialListAPI(restful.Resource):
	def get(self):
		tutorials = Tutorial.query.order_by(Tutorial.id.desc()).all()
		return [t.as_json() for t in tutorials]

	def post(self):
		tut = Tutorial(request.form['title'], 4, 5)
		db.session.add(tut)
		db.session.commit()
		return { tutorial: tut.as_json() }


class TutorialAPI(restful.Resource):
	def get(self, tutorial_id):
		tutorial = Tutorial.query.get(tutorial_id)
		if(tutorial):
			return tutorial.as_json()
		else:
			return {}

	def put(self, tutorial_id):
		tutorial = Tutorial.query.get(tutorial_id)
		if not tutorial:
			restful.abort(404, message='Invalid tutorial')
		try:
			tutorial.x = request.form['x']
			tutorial.y = request.form['y']
		except:
			restful.session.abort(400)
		db.session.commit()
		return 
		
	def delete(self, tutorial_id):
		tutorial = Tutorial.query.get(tutorial_id)
		if not tutorial:
			restful.abort(404, message='Invalid tutorial')
		db.session.delete(tutorial)
		db.session.commit()


class getDependencies(restful.Resource):
	def get(self):
		dependencies = Dependency.query.order_by(Dependency.lower_id.desc()).all()
		return [t.as_json() for t in dependencies]


api.add_resource(TutorialListAPI, '/tutorials')
api.add_resource(TutorialAPI, '/tutorials/<int:tutorial_id>')
api.add_resource(getDependencies, '/dependencies')

if __name__ == '__main__':
	app.run(debug=True)
	db.create_all(app=app)

