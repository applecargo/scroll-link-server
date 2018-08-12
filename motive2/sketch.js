window.onload = function() {

  //graphics - paperjs

  paper.install(window);

  paper.setup(document.getElementById('paperjs'));

  var posxs = [];
  var lines = [];
  function filluplines( step ) {
    //fill-up a rectangular area with vertical lines (automatically)
    //line density change
    //center
    var cx = view.size.width / 2;
    //refresh posxs
    posxs.splice(0);
    posxs.push(cx); // the center
    // center --> 0
    var posx = cx;
    while(posx >= 0) {
      posx = posx - step;
      posxs.push(posx);
    }
    // center --> view.size.width
    var posx = cx;
    while(posx <= view.size.width) {
      posx = posx + step;
      posxs.push(posx);
    }
    //result
    // console.log(lines);
    //remove all for redraw
    lines.forEach(function(item) {
      item.remove();
    });
    lines.splice(0);
    posxs.forEach(function (item) {
      lines.push(new Path.Line({
        from: [item, 0],
        to: [item, view.size.height],
        strokeWidth: 1,
        strokeColor: 'black'
      }));
    });
  }

  view.onFrame = function(event) {
    //odom_obj.full : range - 0 ~ 5000
    //step : range - 5-500
    //odom_obj.integral = map2(odom_obj.integral / 5000, [0, 5000]);
    //odom_obj.full = map2(odom_obj.full / 5000, [0, 5000]);
    var exp = Math.exp(odom_obj.full / 5000);
    var step = map(exp, [1, Math.E], [5, 500]);
    filluplines(step);
    console.log(exp);
  };

  //left stripe
  var left = new Path.Rectangle({
    point: new Point(0, 0),
    size: [view.size.width / 2, view.size.height],
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
    odom: {
      full: 0,
      integral: 0,
      momentary: 0
    }
  }).sendToBack();

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
    // //emit 'odom_target & odom_obj'
    // socket.emit('scroll', {
    //   odom_target: odom_target,
    //   odom_full: odom_obj.full
    // });
  });

  hm.on('panend', function(ev) {
    odom_obj.integral += ev.deltaY;
    odom_obj.full = odom_obj.integral;
  });
}
