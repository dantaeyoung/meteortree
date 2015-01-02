# all the imports
import sqlite3
from flask import Flask, request, session, g, redirect, url_for, abort, render_template, flash
from flask.ext import restful
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
			return redirect(url_for('show_entries'))
	return render_template('login.html', error=error)

@app.route('/logout')
def logout():
	session.pop('logged_in', None)
	flash('You were logged out')
	return redirect(url_for('show_entries'))

@app.route('/')
def root():
	return show_entries()

@app.route('/')
def show_entries():
	cur = g.db.execute('select title, text, id from entries order by id desc')
	entries = [dict(title=row[0], text=row[1], id=row[2]) for row in cur.fetchall()]
	return render_template('show_entries.html', entries=entries)

@app.route('/add', methods=['POST'])
def add_entry():
	if not session.get('logged_in'):
		abort(401)
	cur = g.db.execute('select title, text, id from entries where title = ?', [request.form['title']])
	firstres = cur.fetchone()
	g.db.execute('insert into entries (title, text) values (?, ?)',
			 [request.form['title'], request.form['text']])
	g.db.commit()
	flash('New entry was successfully posted')
	return redirect(url_for('show_entries'))

@app.route('/delete/<entry_id>')
def delete_entry(entry_id):
	if not session.get('logged_in'):
		abort(401)
	g.db.execute('delete from entries where id= ?', [entry_id])
	g.db.commit()
	flash('Entry was succesfully removed')
	return redirect(url_for('show_entries'))

@app.route('/entry/<entry_id>')
def show_entry(entry_id):
	cur = g.db.execute('select title, text, id from entries where id = ?', [entry_id])
	row = cur.fetchone()
	entry = dict(title=row[0], text=row[1], id=row[2])
	return render_template('show_entry.html', entry=entry)

class getTutorials(restful.Resource):
    def get(self):
		cur = g.db.execute('select title, text, id from entries order by id desc')
		entries = [dict(title=row[0], text=row[1], id=row[2]) for row in cur.fetchall()]
		return entries

class putTutorials(restful.Resource):
    def post(self):
		cur = g.db.execute('select title, text, id from entries order by id desc')
		entries = [dict(title=row[0], text=row[1], id=row[2]) for row in cur.fetchall()]
		return entries

api.add_resource(getTutorials, '/tutorials')
api.add_resource(putTutorials, '/tutorials/new')


if __name__ == '__main__':
	app.debug = True
	app.run()



