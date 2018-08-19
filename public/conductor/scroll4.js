var scroll = {};

$(document).ready(function() {

  paper.install(window);

  paper.setup(document.getElementById('paperjs1'));
  var project1 = project;
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
  }

  paper.setup(document.getElementById('paperjs2'));
  var project2 = project;
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
  }

  paper.setup(document.getElementById('paperjs3'));
  var project3 = project;
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
  }

  paper.setup(document.getElementById('paperjs4'));
  var project4 = project;
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
  }

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
        break;
      case 'b':
        project2.activate();
        project2.view.center = [
          project2.view.center.x,
          scroll[msg.key].value
        ];
        break;
      case 'c':
        project3.activate();
        project3.view.center = [
          project3.view.center.x,
          scroll[msg.key].value
        ];
        break;
      case 'd':
        project4.activate();
        project4.view.center = [
          project4.view.center.x,
          scroll[msg.key].value
        ];
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
    if (ev.center.x < window.innerWidth / 4 * 1) {
      scrollkey = 'a';
    } else if (ev.center.x < window.innerWidth / 4 * 2) {
      scrollkey = 'b';
    } else if (ev.center.x < window.innerWidth / 4 * 3) {
      scrollkey = 'c';
    } else if (ev.center.x < window.innerWidth / 4 * 4) {
      scrollkey = 'd';
    }
    if (scroll[scrollkey] != undefined) {
      throttled_send(scrollkey, scroll[scrollkey].value, true);
      //DEBUG: now simply get it.
      scrollactive = true;
      scrollold = scroll[scrollkey].value;
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
      } else if (scrollkey == 'c') {
        project3.activate();
        project3.view.center = [
          project3.view.center.x,
          scroll[scrollkey].value
        ];
      } else if (scrollkey == 'd') {
        project4.activate();
        project4.view.center = [
          project4.view.center.x,
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
      } else if (scrollkey == 'c') {
        project3.activate();
        project3.view.center = [
          project3.view.center.x,
          scroll[scrollkey].value
        ];
      } else if (scrollkey == 'd') {
        project4.activate();
        project4.view.center = [
          project4.view.center.x,
          scroll[scrollkey].value
        ];
      }
      //release my holding
      scrollactive = false;
    }
  });

});
