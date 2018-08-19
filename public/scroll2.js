var scroll = {};

$(document).ready(function() {

  paper.install(window);

  var patterns = {};

  paper.setup(document.getElementById('paperjs1'));
  var project1 = project;
  var pattern1 = [];
  var SCENE_W = view.size.width;
  var SCENE_H = 5000;
  var step = 30;
  var n = SCENE_H / step;
  for (var idx = 0; idx < n; idx++) {
    var r = new Path.Line({
      from: [-20 * idx, step * idx],
      to: [2 * step * idx, 0],
      strokeWidth: idx / 10,
      // dashArray: [idx, 20],
      strokeColor: 'black',
    });
    r.rotate(-0.5 * idx);
    pattern1.push(r);
  }
  patterns['a'] = pattern1;

  paper.setup(document.getElementById('paperjs2'));
  var project2 = project;
  var pattern2 = [];
  SCENE_W = view.size.width;
  SCENE_H = 5000;
  step = 100;
  n = SCENE_H / step;
  for (var idx = 0; idx < n; idx++) {
    var r = new Shape.Rectangle({
      center: [SCENE_W / 2, step * idx],
      size: [idx * 2.2 + 2, idx * 2 + 2],
      fillColor: 'black',
    });
    pattern2.push(r);
  }
  patterns['b'] = pattern2;

  var socket = io('http://192.168.1.105:8080');
  //var socket = io('https://choir.run');
  socket.on('connect', function() {
    console.log("i' m connected!");
  });

  socket.on('scroll', function(msg) {
    scroll[msg.key] = {
      value: msg.data.value,
      islocked: msg.data.islocked
    };

    switch (msg.key) {
      case 'a':
        project1.activate();
        project1.view.center = [
          project1.view.center.x,
          scroll[msg.key].value
        ];
        if (msg.data.islocked == true) { //locking - active
          $('.paperjs').eq(0).removeClass('bg-white');
          $('.paperjs').eq(0).addClass('bg-red');
        } else { //unlocking - inactive
          $('.paperjs').eq(0).removeClass('bg-red');
          $('.paperjs').eq(0).addClass('bg-white');
        }
        break;
      case 'b':
        project2.activate();
        project2.view.center = [
          project2.view.center.x,
          scroll[msg.key].value
        ];
        if (msg.data.islocked == true) { //locking - active
          $('.paperjs').eq(1).removeClass('bg-white');
          $('.paperjs').eq(1).addClass('bg-orange');
        } else { //unlocking - inactive
          $('.paperjs').eq(1).removeClass('bg-orange');
          $('.paperjs').eq(1).addClass('bg-white');
        }
        break;
      default:
        ;
    }
  });

  //emit scroll signal
  function sendscroll(key, value, islocked) {
    socket.emit('scroll', {
      key: key,
      data: {
        value: value,
        islocked: islocked
      }
    });
  }
  var throttled_send = _.throttle(sendscroll, 100);

  //user interaction - hammer.js

  var hm = new Hammer.Manager(window);
  hm.add(new Hammer.Pan({
    direction: Hammer.DIRECTION_VERTICAL
  }));
  var scrollactive = false;
  var scrollold = 0;
  var scrollkey = '';
  hm.on('panstart', function(ev) {
    if (ev.center.x < window.innerWidth / 2 * 1) {
      scrollkey = 'a';
    } else if (ev.center.x < window.innerWidth / 2 * 2) {
      scrollkey = 'b';
    }
    if (scroll[scrollkey] != undefined) {
      //try 'get'
      console.log('getting scroll...');
      socket.emit('scroll-get', scrollkey, function (response) {
        console.log(response);
        if (response == true) {
          scrollactive = true;
          scrollold = scroll[scrollkey].value;
          //
          if (scrollkey == 'a') {
            patterns[scrollkey].forEach(function (item) {
              item.strokeColor = new Color({
                hue: getRandom(0, 360),
                saturation: 1,
                brightness: 1
              });
            });
          }
          else {
            patterns[scrollkey].forEach(function (item) {
              item.fillColor = new Color({
                hue: getRandom(0, 360),
                saturation: 1,
                brightness: 1
              });
            });
          }
        }
      });
    }
  });
  hm.on('panmove', function(ev) {
    if (scrollactive == true) {
      scroll[scrollkey].value = scrollold - ev.deltaY;
      if (scroll[scrollkey].value < 0) scroll[scrollkey].value = 0;
      if (scroll[scrollkey].value > SCENE_H) scroll[scrollkey].value = SCENE_H;
      throttled_send(scrollkey, scroll[scrollkey].value, true);
      if (scrollkey == 'a') {
        project1.activate();
        project1.view.center = [
          project1.view.center.x,
          scroll[scrollkey].value
        ];
      } else if (scrollkey == 'b') {
        project2.activate();
        project2.view.center = [
          project2.view.center.x,
          scroll[scrollkey].value
        ];
      }
    }
  });
  hm.on('panend', function(ev) {
    if (scrollactive == true) {
      scroll[scrollkey].value = scrollold - ev.deltaY;
      if (scroll[scrollkey].value < 0) scroll[scrollkey].value = 0;
      if (scroll[scrollkey].value > SCENE_H) scroll[scrollkey].value = SCENE_H;
      throttled_send(scrollkey, scroll[scrollkey].value, false);
      if (scrollkey == 'a') {
        project1.activate();
        project1.view.center = [
          project1.view.center.x,
          scroll[scrollkey].value
        ];
      } else if (scrollkey == 'b') {
        project2.activate();
        project2.view.center = [
          project2.view.center.x,
          scroll[scrollkey].value
        ];
      }
      //release my holding
      scrollactive = false;
      patterns[scrollkey].forEach(function (item) {
        if (scrollkey == 'a') {
          item.strokeColor = new Color('black');
        }
        else {
          item.fillColor = new Color('black');
        }
      });
    }
  });

});
