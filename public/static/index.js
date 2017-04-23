(function() {
    var app = Elm.Main.fullscreen();

    app.ports.connect.subscribe(function(url) {
        var socket = io(url);
        socket.on('event', function(data) {
            console.log(data);
            app.ports.onMessage.send(data);
        });
    });
})();
