#Filesystem Utilities
fs = require 'fs'
path = require 'path'

#The express server
express = require 'express'
app = express()

app.use express.static __dirname + '/files/'
app.listen 8080

app.get '/', (req, res) ->
	res.sendFile __dirname + '/files/index.html'

#Websocket Server
server = require('http').Server(app)
server.listen 8081
io = require('socket.io') (server)

io.on 'connection', (socket) ->
	fs.readFile __dirname + '/files/views/login.html' , 'utf8', (err,data) ->
		socket.emit 'render', data
		socket.on 'login', (data) ->
			email = data.split('&')[0]
			password = data.split('&')[1] 
			if authenticate email, password
				fs.readFile __dirname + '/files/views/main.html', 'utf8', (err, data) ->
					socket.emit 'render', data
					User.findOne 'email': email, (err, user) ->
						for i in user.friends
							socket.emit 'friend', user.friends[i]
						for i in user.requests
							socket.emit 'request', user.requests[i]
				
						socket.on 'addfriend', (data) ->
							console.log user.username
							console.log data
							addFriend user.username, data

		socket.on 'reqregister', ->
			fs.readFile __dirname + '/files/views/register.html', 'utf8', (err, data) ->
				socket.emit 'render', data
				socket.on 'register', (data) ->
					createUser data.split('&')[0], data.split('&')[1], data.split('&')[2], (success) ->
						if success
							fs.readFile __dirname + '/files/views/login.html' , 'utf8', (err,data) ->
								socket.emit 'render', data
						else
							socket.emit 'nonunique'
					


login = (socket, email) ->



#The database server stuff
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/IM'
db = mongoose.connection
Schema = mongoose.Schema

UserSchema = new Schema
	username:
		type: String
		unique: true
	password:
		type: String
	friends : [
		username: String
	]
	requests : [
		username : String
	]
	email:
		type: String
		unique: true

User = mongoose.model('User', UserSchema)

createUser = (username, email, password, callback) ->
	User.create username: username, email: email, password: password, (err, user) ->
		return callback true if user
		return callback false
	
updateRecord = (username, record, value) ->
	User.update username: username, record:value

deleteUser = (username) ->
	User.findOne('username': username).remove().exec()

addFriend = (username, friendname) ->
	User.findOne 'username': friendname, 'requests', (err, friend) ->
		User.findOne 'username': username, 'friends', (err, user) ->
			console.log friend
			console.log user
			user.friends.push friendname
			friend.requests.push username
			user.save()
			friend.save()



addRequest = (user, friend) ->
	User.findOne 'username': user , 'friends requests', (err,user) ->
		user.friends += friend
		user.requests.splice user.requests.indexOf(friend) , 1

removeRequest = (username, friend) ->
	User.findOne 'username': username, 'requests' , (err, user) ->
		User.findOne 'username': friend, 'friends', (err, friend) ->
			user.requests.splice user.requests.indexOf(friend) , 1
			friend.friends.splice friend.friends.indexOf(username), 1

getUser = (email) ->
	User.findOne 'email': email, 'username', (err, user) ->
		return user.username

getFriends = (email) ->
	User.findOne 'username': username, 'friends', (err, user) ->
		return user.friends

authenticate = (email, password) ->
	User.findOne 'email':email, 'password',(err, user) ->
		return typeof user == null or password == user.password