from flasktree import app, db

if __name__ == '__main__':
	app.run(debug=True)
	db.create_all(app=app)

