const ws = new WebSocket('ws://localhost:8080/websocket');

ws.onopen = function () {
    console.log('WebSocket connection established');
    ws.send('Hello Server!');
};

ws.onmessage = function (event) {
    console.log('Received message from server:', event.data);
};

ws.onerror = function (error) {
    console.error('WebSocket error:', error);
};

ws.onclose = function () {
    console.log('WebSocket connection closed');
};