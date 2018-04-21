function getHost() {
  return window.location.host;
}

(function() {
  var app = Elm.Main.fullscreen({
    host: getHost()
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
