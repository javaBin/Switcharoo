function getHost() {
    return window.location.protocol + '//' + window.location.host;
}

(function() {
    var app = Elm.Main.fullscreen({
        host: getHost()
    });

    app.ports.connect.subscribe(function(url) {
        var socket = io(url);
        socket.on('event', function(data) {
            console.log(data);
            app.ports.onMessage.send(data);
        });
    });
})();
