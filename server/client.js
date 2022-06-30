const WebSocket = require('ws');

const webSocket = new WebSocket('ws://178.20.41.205:8081');

webSocket.on('message', function (msg) {
    console.log("message: " + msg);
    let message = JSON.parse(msg);
});

webSocket.onopen = function() {
    console.log("open!");
    webSocket.send(JSON.stringify({
        'action': "spam",
        //'username': 'delta_null',
    }));
};