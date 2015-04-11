socket = io.connect '::8081'

socket.on 'render', (data) ->
	$('#view').empty()
	$('#view').html(data)

socket.on 'run', (data) ->
	eval data

socket.on 'friend', (data) ->
	$('#friends').append $('<li>').text data 

socket.on 'request', (data) ->
	toastr.info 'You got a friend request from: ' + data

socket.on 'nonunique', ->
	toastr.error 'either your username or email has already been used, please use a different one'

login = ->
	email = $('#inputEmail').val()
	password = (CryptoJS.SHA3 $('#inputPassword').val()).toString()
	socket.emit 'login', email + '&' + password

reqregister = ->
	socket.emit 'reqregister'

register = ->
	username = $('#inputuser').val()
	email = $('#inputEmail').val()
	if email == $('#inputConfirmEmail').val()
		password = (CryptoJS.SHA3 $('#inputPassword').val()).toString()
		confirmPassword = (CryptoJS.SHA3 $('#inputConfirmPassword').val()).toString()
		if password == confirmPassword
			socket.emit 'register', username + '&' + email + '&' + password

addfriend = ->
	username = $('#addfriend').val()
	console.log 'adding: ' + username
	socket.emit 'addfriend', username