// scroll-link node server
// var fs = require('fs');

//NOTE: SERVER CONFIGURATION has 2 options. ENABLE 1 of 2 options

// //NOTE: option (1) - https server (443) + redirection 80 to 443
//
// //prepare credentials & etc
// var https = require('https');
// var privateKey = fs.readFileSync('/etc/letsencrypt/live/choir.run/privkey.pem', 'utf8');
// var certificate = fs.readFileSync('/etc/letsencrypt/live/choir.run/fullchain.pem', 'utf8');
// var credentials = {
//   key: privateKey,
//   cert: certificate
// };
//
// //https WWW server @ port 443
// var express = require('express');
// var app = express();
// var httpsWebServer = https.createServer(credentials, app).listen(443, function() {
//   console.log('[express] listening on *:443');
// });
//
// //http Redirection server @ port 80
// //  ==> Don't get why this works.. all others not. ==> https://stackoverflow.com/a/23283173
// var http = require('http');
// var httpApp = express();
// var httpRouter = express.Router();
// httpApp.use('*', httpRouter);
// httpRouter.get('*', function(req, res) {
//   var host = req.get('Host');
//   // replace the port in the host
//   host = host.replace(/:\d+$/, ":" + app.get('port'));
//   // determine the redirect destination
//   var destination = ['https://', host, req.url].join('');
//   return res.redirect(destination);
// });
// var httpServer = http.createServer(httpApp);
// httpServer.listen(80);
//
// //https socket.io server @ port 443 (same port as WWW service)
// var io = require('socket.io')(httpsWebServer, {
//   'pingInterval': 1000,
//   'pingTimeout': 3000
// });

//NOTE: option (2) - simple http dev server (8080)

var http = require('http');
var express = require('express');
var app = express();
var httpServer = http.createServer(app);
httpServer.listen(8080);

//http socket.io server @ port 8080 (same port as WWW service)
var io = require('socket.io')(httpServer, {
  'pingInterval': 1000,
  'pingTimeout': 3000
});

//express configuration
app.use(express.static('public'));

//// osc.js configuration (UDP)
var osc = require("osc");
var udp_sc = new osc.UDPPort({
  localAddress: '0.0.0.0', //NOTE: '127.0.0.1' doesn't work!!
  localPort: 57121,
  // remoteAddress: '192.168.1.129',
  // remoteAddress: '192.168.1.123',
  //remoteAddress: '10.10.10.71',
  remoteAddress: '0.0.0.0',
  remotePort: 57120,
  metadata: true
});

//firstly establish/ensure osc conn.
udp_sc.on("ready", function() {

  //socket.io events
  io.on('connection', function(socket) {

    //entry log.
    console.log('someone connected.');

    //msg. for everybody - scroll events
    socket.on('scroll', function(msg) {

      //websocket clients: sending to all clients except sender
      socket.broadcast.emit('scroll', msg);
      console.log('scroll :');
      console.log(msg);

      //osc clients: send '/odom
      udp_sc.send({
        address: "/odom",
        args: [{
          type: "i",
          value: msg.odom_target
        }, {
          type: "i",
          value: msg.odom_full
        }]
      });
    });

    //exit log.
    socket.on('disconnect', function() {
      console.log('someone disconnected.');
    });

  });

});

// //message handler
// udp_sc.on("message", function(oscmsg, timetag, info) {
//   console.log("[udp] got osc message:", oscmsg);
//
//   //EX)
//   // //method [1] : just relay as a whole
//   // io.emit('osc-msg', oscmsg); //broadcast
//
//   //EX)
//   // //method [2] : each fields
//   // io.emit('osc-address', oscmsg.address); //broadcast
//   // io.emit('osc-type', oscmsg.type); //broadcast
//   // io.emit('osc-args', oscmsg.args); //broadcast
//   // io.emit('osc-value0', oscmsg.args[0].value); //broadcast
//
//   //just grab i need.. note!
//   io.emit('sing-note', oscmsg.address); //broadcast
// });

//osc.js - start service
udp_sc.open();
udp_sc.on("ready", function() {
  console.log(
    "[udp] ready : \n" +
    "\treceive@" + udp_sc.options.localAddress + ":" + udp_sc.options.localPort + "\n" +
    "\tsend@" + udp_sc.options.remoteAddress + ":" + udp_sc.options.remotePort + "\n"
  );
});