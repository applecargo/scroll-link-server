window.onload = function() {

  //graphics - paperjs

  paper.install(window);

  var colors = [
    '#8B6969', '#BC8F8F', '#C67171', '#EEB4B4', '#F08080', '#C65D57',
    '#CDB7B5', '#FC1501', '#8B7D7B', '#CD5B45', '#8B4C39', '#A78D84',
    '#CD8162', '#D19275', '#FF9955', '#FFF5EE', '#EEE5DE', '#CDAF95',
    '#E7C6A5', '#C9AF94', '#9F703A', '#CDC0B0', '#CDBA96', '#FFFAF0'
  ];

  paper.setup(document.getElementById('paperjs'));

  //left stripe
  var left = new Path.Rectangle({
    point: new Point(0, 0),
    size: [view.size.width / 2, view.size.height],
    fillColor: '#EDC393',
    onFrame: function(event) {
      var select = Math.floor(Math.abs(this.odom.full / 1000));
      this.fillColor = colors[select % colors.length];
    },
    odom: {
      full: 0,
      integral: 0,
      momentary: 0
    }
  }).sendToBack();

  //right stripe
  var right = new Path.Rectangle({
    point: new Point(view.size.width / 2, 0),
    size: [view.size.width / 2, view.size.height],
    fillColor: '#EDC393',
    onFrame: function(event) {
      var select = Math.floor(Math.abs(this.odom.full / 1000));
      this.fillColor = colors[select % colors.length];
    },
    odom: {
      full: 0,
      integral: 0,
      momentary: 0
    }
  }).sendToBack();

  //networking - socket.io

  var socket = io('http://192.168.1.105:8080');
  // var socket = io('http://10.10.10.239:8080');
  socket.on('connect', function() {
    console.log("i' m connected!");
  });

  //user interaction - hammer.js

  var hm = new Hammer.Manager(window);
  hm.add(new Hammer.Pan({
    direction: Hammer.DIRECTION_VERTICAL
  }));
  var odom_obj = left.odom;
  var odom_target = 0; //0: left stripe, 1: right stripe
  hm.on('panstart', function(ev) {
    if (ev.center.x <= view.size.width / 2) {
      odom_target = 0;
      odom_obj = left.odom;
    } else {
      odom_target = 1;
      odom_obj = right.odom;
    }
  });

  hm.on('panmove', function(ev) {
    odom_obj.momentary = ev.deltaY;
    odom_obj.full = odom_obj.integral + odom_obj.momentary;
    var msg = "type : " + ev.type + "<br/>ev.deltaY : " + ev.deltaY + "<br/>odom_obj.full : " + odom_obj.full;
    $('#objstring').html(msg);
    //emit 'odom_target & odom_obj'
    socket.emit('scroll', {
      odom_target: odom_target,
      odom_full: odom_obj.full
    });
  });

  hm.on('panend', function(ev) {
    odom_obj.integral += ev.deltaY;
    odom_obj.full = odom_obj.integral;
  });

  socket.on('scroll', function(msg) {
    if (msg.odom_target == 0) {
      left.odom.integral = msg.odom_full;
      left.odom.full = msg.odom_full;
    } else if (msg.odom_target == 1) {
      //deep copy
      right.odom.integral = msg.odom_full;
      right.odom.full = msg.odom_full;
    }
    //
    var msg = "a network msg. received! : <br/>" + JSON.stringify(msg);
    $('#objstring').html(msg);
  });

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
