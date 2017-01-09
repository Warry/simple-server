var http = require('http');
var port = 8080;
var Elm = require('./dist/main.js');

// Start the app
var app = Elm.Main.worker();

// Bind the responses
app.ports.outgoingRequest.subscribe(function([callback, response]) {
    callback().writeHead(response.status, {'Content-Type': 'text/plain'});
    callback().end(response.body);
});

// Bind the requests
var server = http.createServer(function(req, response){
    app.ports.incomingRequest.send(
        [()=> response,
        { headers : req.headers
        , method : req.method
        , url : req.url
        }]);
});

// Start the server
server.listen(port, function(){
    console.log("Server listening on: http://localhost:%s (ctrl+click to open)", port);
});

