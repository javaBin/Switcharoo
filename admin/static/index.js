function getHost() {
  return window.location.protocol + '//' + window.location.host;
}

(function() {
  var token = localStorage.getItem('login_token');
  var app = Elm.Main.fullscreen({
    loggedIn: token ? true : false,
    host: getHost()
  });

  var lock = new Auth0Lock(
    'CF27t8eOHL1aPxAMgI10LsairXK4B2Ap',
    'switcharoo.eu.auth0.com'
  );
  if (token) {
    getUserInfo({
      idToken: token
    });
  }

  function checkStatus(response) {
    if (response.status >= 200 && response.status < 300) {
      return response;
    } else {
      var error = new Error(response.statusText);
      error.response = response;
      throw error;
    }
  }

  function getUserInfo(result) {
    lock.getProfile(result.idToken, function(error, profile) {
      if (error) {
        if (error.error === 401) {
          localStorage.removeItem('login_token');
        }
        console.log(error);
        return;
      }

      localStorage.setItem('login_token', result.idToken);
      setTimeout(function() {
        app.ports.loginResult.send({
          token: result.idToken,
          profile: profile
        });
      }, 100);
    });
  }

  function parseJson(response) {
    return response.json();
  }

  app.ports.fileSelected.subscribe(function(id) {
    var input = document.getElementById(id);
    if (input == null) {
      return;
    }

    var data = new FormData();
    data.append('image', input.files[0]);

    fetch('/image', {
      method: 'POST',
      body: data
    })
      .then(checkStatus)
      .then(parseJson)
      .then(function(data) {
        app.ports.fileUploadSucceeded.send(data);
      })
      .catch(function(error) {
        app.ports.fileUploadFailed.send(error.message);
      });
  });

  app.ports.login.subscribe(function() {
    lock.show();
  });

  lock.on('authenticated', getUserInfo);

  app.ports.connect.subscribe(function(url) {
    var socket = io(url);
    socket.on('event', function(data) {
      console.log(data);
      app.ports.onMessage.send(data);
    });
  });
})();
