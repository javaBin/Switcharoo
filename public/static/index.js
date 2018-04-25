function getHost() {
  return window.location.host;
}

function isSecure() {
  return window.location.protocol === 'https:';
}

(function() {
  var app = Elm.Main.fullscreen({
    host: getHost(),
    secure: isSecure()
  });

  window.onhashchange = function() {
    window.location.reload();
  };

  var conference = window.location.hash.slice(1);
  if (conference === '') {
    return;
  }

  var link = document.createElement('link');
  link.href = '/custom.css/' + conference;
  link.type = 'text/css';
  link.rel = 'stylesheet';
  var head = document.querySelector('head');
  head.appendChild(link);
})();
