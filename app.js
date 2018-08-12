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
//app.use(express.static('public'));
//app.use(express.static('motive1'));
//app.use(express.static('motive2'));
app.use(express.static('numbers'));

//// osc.js configuration (UDP)
var osc = require("osc");
var soundserver_ip = '224.2.2.2';
//apps cannot share port.. (pd & sc)
//for puredata : tx: 57000, rx: 57001
var udp_pd = new osc.UDPPort({
  localAddress: '0.0.0.0', //NOTE: '127.0.0.1' doesn't work!!
  localPort: 57001,
  remoteAddress: soundserver_ip,
  remotePort: 57000,
  metadata: true
});
//for supercollider : tx: 57120, rx: 57121
var udp_sc = new osc.UDPPort({
  localAddress: '0.0.0.0', //NOTE: '127.0.0.1' doesn't work!!
  localPort: 57121,
  remoteAddress: soundserver_ip,
  remotePort: 57120,
  metadata: true
});

//'scroll' status array
var scroll = {};
scroll['a'] = {
  value: 0,
  islocked: false
};
scroll['b'] = {
  value: 0,
  islocked: false
};
scroll['c'] = {
  value: 0,
  islocked: false
};
scroll['d'] = {
  value: 0,
  islocked: false
};
scroll['e'] = {
  value: 0,
  islocked: false
};
scroll['f'] = {
  value: 0,
  islocked: false
};
scroll['g'] = {
  value: 0,
  islocked: false
};
scroll['h'] = {
  value: 0,
  islocked: false
};
scroll['i'] = {
  value: 0,
  islocked: false
};
scroll['j'] = {
  value: 0,
  islocked: false
};

//firstly establish/ensure osc conn. - supercollider & puredata
Promise.all([
  new Promise(function(resolve, reject) { udp_pd.on("ready", function() { resolve(0); console.log('udp_pd ready..'); } ); }),
  new Promise(function(resolve, reject) { udp_sc.on("ready", function() { resolve(0); console.log('udp_sc ready..'); } ); }),
]).then(function(results) {
    //socket.io events
    io.on('connection', function(socket) {

      //entry log.
      console.log('someone connected.');

      //let a new client be up-to-date
      Object.keys(scroll).forEach(function(key) { // ES6 --> https://stackoverflow.com/a/5737192
        socket.emit('scroll', {
          key: key,
          data: scroll[key]
        });
      });

      //msg. for everybody - scroll events
      socket.on('scroll', function(msg) {

        //update server's status array
        scroll[msg.key].value = msg.data.value;
        scroll[msg.key].islocked = msg.data.islocked;

        //websocket clients: sending to all clients except sender
        //relay the message to everybody
        socket.broadcast.emit('scroll', msg);

        //DEBUG
        //console.log('scroll :');
        console.log(msg);

        //osc clients: send '/scroll
        udp_pd.send({
          address: "/scroll",
          args: [{
            type: "s",
            value: msg.key
          }, {
            type: "f",
            value: msg.data.value
          }]
        });
        //
        udp_sc.send({
          address: "/scroll",
          args: [{
            type: "s",
            value: msg.key
          }, {
            type: "f",
            value: msg.data.value
          }]
        });
      });

      //exit log.
      socket.on('disconnect', function() {
        console.log('someone disconnected.');

        //TODO: BUG: disconnection one's 'locked' keys must be released! otherwise, nobody can use it! (even the one who locked it, when returned.)
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
udp_pd.open();
udp_pd.on("ready", function() {
  console.log(
    "[udp] ready (udp_pd) : \n" +
      "\tlistening on --> " + udp_pd.options.localAddress + ":" + udp_pd.options.localPort + "\n" +
      "\tspeaking to -> " + udp_pd.options.remoteAddress + ":" + udp_pd.options.remotePort + "\n"
  );
});
udp_sc.open();
udp_sc.on("ready", function() {
  console.log(
    "[udp] ready (udp_sc) : \n" +
      "\tlistening on --> " + udp_sc.options.localAddress + ":" + udp_sc.options.localPort + "\n" +
      "\tspeaking to -> " + udp_sc.options.remoteAddress + ":" + udp_sc.options.remotePort + "\n"
  );
});
