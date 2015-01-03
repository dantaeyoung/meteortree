# all the imports
import sqlite3
from flask import Flask, request, session, g, redirect, url_for, abort, render_template, flash
from flask.ext import restful
from flask.ext.sqlalchemy import SQLAlchemy
from contextlib import closing


# configuration
DATABASE = '/tmp/flaskr.db'
DEBUG = True
SECRET_KEY = 'development key'
USERNAME = 'admin'
PASSWORD = 'default'

app = Flask(__name__)
api = restful.Api(app)

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

	def getDict(self):
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
	with closing(connect_db()) as db:
		with app.open_resource('schema.sql', mode='r') as f:
			db.cursor().executescript(f.read())
		db.commit()

def connect_db():
	return sqlite3.connect(app.config['DATABASE'])

@app.before_request
def before_request():
    g.db = connect_db()

@app.teardown_request
def teardown_request(exception):
	db = getattr(g, 'db', None)
	if db is not None:
		db.close()

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
	Tutorial.query.filter_by(id=tutorial_id).delete()
	db.session.commit()

	flash('Entry was succesfully removed')
	return redirect(url_for('show_tutorials'))

@app.route('/tutorial/<tutorial_id>')
def show_tutorial(tutorial_id):
	tutorial = Tutorial.query.filter_by(id=tutorial_id).first()
	return render_template('show_tutorial.html', tutorial=tutorial)





class getTutorials(restful.Resource):
	def get(self):
		tutorials = Tutorial.query.order_by(Tutorial.id.desc()).all()
		return [t.getDict() for t in tutorials]

class putTutorials(restful.Resource):
	def post(self):
		cur = g.db.execute('select title, iconPath, id from tutorials order by id desc')
		tutorials = [dict(title=row[0], text=row[1], id=row[2]) for row in cur.fetchall()]
		return tutorials

class editTutorial(restful.Resource):
	def get(self, tutorial_id):
		#return tutorial_id
		tutorial = Tutorial.query.filter_by(id=tutorial_id).first()
		if(tutorial):
			return tutorial.getDict()
		else:
			return {}

	def post(self, tutorial_id):
		tutorial = Tutorial.query.filter_by(id=tutorial_id).first()
		tutorial.x = request.form['x']
		tutorial.y = request.form['y']
		db.session.commit()
		return 

class getDependencies(restful.Resource):
	def get(self):
		dependencies = Dependency.query.order_by(Dependency.lower_id.desc()).all()
		return [t.getDict() for t in dependencies]

api.add_resource(getTutorials, '/tutorials')
api.add_resource(putTutorials, '/tutorials/new')
api.add_resource(editTutorial, '/tutorials/<int:tutorial_id>')
api.add_resource(getDependencies, '/dependencies')

if __name__ == '__main__':
	app.debug = True
	app.run()



