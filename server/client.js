const WebSocket = require('ws');

const webSocket = new WebSocket('ws://127.0.0.1:8081');

webSocket.on('message', function (msg) {
    console.log("message: " + msg);
    let message = JSON.parse(msg);
});

webSocket.onopen = function() {
    console.log("open!");
    webSocket.send(JSON.stringify({
        'action': "login",
        'username': 'delta_null',
    }));
};