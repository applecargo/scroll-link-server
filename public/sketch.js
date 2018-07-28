window.onload = function() {

  //paperjs @ canvas (id: 'paperjs')

  paper.install(window);
  paper.setup(document.getElementById('paperjs'));
  var colors = [];
  colors.push('#8B6969');
  colors.push('#BC8F8F');
  colors.push('#C67171');
  colors.push('#EEB4B4');
  colors.push('#F08080');
  colors.push('#C65D57');
  colors.push('#CDB7B5');
  colors.push('#FC1501');
  colors.push('#8B7D7B');
  colors.push('#CD5B45');
  colors.push('#8B4C39');
  colors.push('#A78D84');
  colors.push('#CD8162');
  colors.push('#D19275');
  colors.push('#FF9955');
  colors.push('#FFF5EE');
  colors.push('#EEE5DE');
  colors.push('#CDAF95');
  colors.push('#E7C6A5');
  colors.push('#C9AF94');
  colors.push('#9F703A');
  colors.push('#CDC0B0');
  colors.push('#CDBA96');
  colors.push('#FFFAF0');

  var back = new Path.Rectangle({
    point: new Point(0, 0),
    size: view.size,
    fillColor: '#EDC393'
  }).sendToBack();

  //socket.io
  var socket = io('http://192.168.1.129:8080');
  socket.on('connect', function() {
    console.log("i' m connected!");
  });

  //user interaction - hammer.js

  var hm = new Hammer.Manager(window);
  hm.add(new Hammer.Pan({
    direction: Hammer.DIRECTION_VERTICAL
  }));
  var odom_integral = 0;
  var odom_momentary = 0;
  var odom = 0;
  hm.on('panmove', function(ev) {
    odom_momentary = ev.deltaY;
    odom = odom_integral + odom_momentary;
    var msg = "type : " + ev.type + "<br/>ev.deltaY : " + ev.deltaY + "<br/>odom : " + odom;
    $('#objstring').html(msg);
    //
    //emit 'odom'
    socket.emit('scroll', {
      odom_integral: odom_integral,
      odom_momentary: odom_momentary
    });
    //
    var select = Math.floor(Math.abs(odom / 1000));
    back.fillColor = colors[select % colors.length];
  });

  hm.on('panend', function(ev) {
    odom_integral += ev.deltaY;
    odom = odom_integral + odom_momentary;
  });

  socket.on('scroll', function(odom) {
    odom_momentary = odom.odom_momentary;
    odom_integral = odom.odom_integral;
    odom = odom_integral + odom_momentary;
    //
    var msg = "network msg. received! : odom : " + odom;
    $('#objstring').html(msg);
    //
    var select = Math.floor(Math.abs(odom / 1000));
    back.fillColor = colors[select % colors.length];
  });

  function onFrame(event) {
    var select = Math.floor(Math.abs(odom / 1000));
    back.fillColor = colors[select % colors.length];
  }

  // //p5 canvas setup
  // new p5(function(p) {
  //   p.setup = function() {
  //     p.createCanvas(window.innerWidth, window.innerHeight);
  //   };
  //   p.draw = function() {
  //     p.background(125);
  //     console.log(window.scrollY);
  //   };
  // });

}