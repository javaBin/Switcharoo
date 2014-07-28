/*
	Copy me into the file `configuration.js` and fill in the blanks
*/

var config = {
	app: {
		admin: '',
		port: 1337,
		user: '',
		pass: '',
		env: ''
	},
	
	twitter: {
		consumer_key: '',
		consumer_secret: '',
		access_token: '',
		access_token_secret: ''
	},

	instagram: {
		client_id: '',
		client_secret: ''
	},

	mongodb: {
		connection_string: ''
	},

	program: {
		cronPattern: '0 */1 * * * *',
		url: ''
	}
};

module.exports = config;