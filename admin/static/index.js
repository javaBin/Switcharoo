function getHost() {
  return window.location.host;
}

function isSecure() {
  return window.location.protocol === 'https:';
}

function parseJson(response) {
  return response.json();
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

(function() {
  var token = localStorage.getItem('login_token');

  var lock = new Auth0Lock(
    'CF27t8eOHL1aPxAMgI10LsairXK4B2Ap',
    'switcharoo.eu.auth0.com',
    {
      auth: {
        responseType: 'token id_token'
      }
    }
  );

  lock.on('authenticated', function(authResult) {
    localStorage.setItem('login_token', authResult.idToken);
    app.ports.loginResult.send({
      token: authResult.idToken
    });
  });

  lock.on('unrecoverable_error', function(error) {
    console.error(error);
  });

  lock.on('authorization_error', function(error) {
    console.error(error);
  });

  setTimeout(function() {
    var token = localStorage.getItem('login_token');
    if (token) {
      app.ports.loginResult.send({
        token: token
      });
    } else {
      lock.show();
    }
  }, 200);

  var app = Elm.Main.fullscreen({
    loggedIn: token ? true : false,
    host: getHost(),
    secure: isSecure()
  });
  enablePorts(app);

  function enablePorts(app) {
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
  }
})();
