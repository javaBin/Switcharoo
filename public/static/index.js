function getHost() {
  return window.location.protocol + '//' + window.location.host;
}

(function() {
  var conference = window.location.hash.slice(1);
  var app = Elm.Main.fullscreen({
    host: getHost(),
    conference: conference
  });

  window.onhashchange = function() {
    window.location.reload();
  };

  var link = document.createElement('link');
  link.href = '/custom.css/' + conference;
  link.type = 'text/css';
  link.rel = 'stylesheet';
  var head = document.querySelector('head');
  head.appendChild(link);
})();
