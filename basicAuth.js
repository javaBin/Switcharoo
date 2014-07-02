var basicAuth = require('basic-auth');

module.exports = function(username, password) {
	return function(req, res, next) {
		var user = basicAuth(req);
		if (!user) {
			res.writeHead(401, {'WWW-Authenticate': 'Basic realm="Admin"'});
			return res.end();
		}

		if (user.name !== username || user.pass !== password) {
			res.writeHead(401, {'WWW-Authenticate': 'Basic realm="Admin"'});
			return res.end();
		}

		next();
	}
}