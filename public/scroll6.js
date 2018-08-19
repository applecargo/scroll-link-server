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

  paper.setup(document.getElementById('paperjs3'));
  var project3 = project;
  var pattern3 = [];
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
    pattern3.push(r);
  }
  patterns['c'] = pattern3;

  paper.setup(document.getElementById('paperjs4'));
  var project4 = project;
  var pattern4 = [];
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
    pattern4.push(r);
  }
  patterns['d'] = pattern4;

  paper.setup(document.getElementById('paperjs5'));
  var project5 = project;
  var pattern5 = [];
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
    pattern5.push(r);
  }
  patterns['e'] = pattern5;

  paper.setup(document.getElementById('paperjs6'));
  var project6 = project;
  var pattern6 = [];
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
    pattern6.push(r);
  }
  patterns['f'] = pattern6;

  //var socket = io('http://192.168.219.186:8080');
  var socket = io('https://choir.run');
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
      case 'c':
        project3.activate();
        project3.view.center = [
          project3.view.center.x,
          scroll[msg.key].value
        ];
        if (msg.data.islocked == true) { //locking - active
          $('.paperjs').eq(2).removeClass('bg-white');
          $('.paperjs').eq(2).addClass('bg-gold');
        } else { //unlocking - inactive
          $('.paperjs').eq(2).removeClass('bg-gold');
          $('.paperjs').eq(2).addClass('bg-white');
        }
        break;
      case 'd':
        project4.activate();
        project4.view.center = [
          project4.view.center.x,
          scroll[msg.key].value
        ];
        if (msg.data.islocked == true) { //locking - active
          $('.paperjs').eq(3).removeClass('bg-white');
          $('.paperjs').eq(3).addClass('bg-lime');
        } else { //unlocking - inactive
          $('.paperjs').eq(3).removeClass('bg-lime');
          $('.paperjs').eq(3).addClass('bg-white');
        }
        break;
      case 'e':
        project5.activate();
        project5.view.center = [
          project5.view.center.x,
          scroll[msg.key].value
        ];
        if (msg.data.islocked == true) { //locking - active
          $('.paperjs').eq(4).removeClass('bg-white');
          $('.paperjs').eq(4).addClass('bg-light-blue');
        } else { //unlocking - inactive
          $('.paperjs').eq(4).removeClass('bg-light-blue');
          $('.paperjs').eq(4).addClass('bg-white');
        }
        break;
      case 'f':
        project6.activate();
        project6.view.center = [
          project6.view.center.x,
          scroll[msg.key].value
        ];
        if (msg.data.islocked == true) { //locking - active
          $('.paperjs').eq(5).removeClass('bg-white');
          $('.paperjs').eq(5).addClass('bg-blue');
        } else { //unlocking - inactive
          $('.paperjs').eq(5).removeClass('bg-blue');
          $('.paperjs').eq(5).addClass('bg-white');
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
    if (ev.center.x < window.innerWidth / 6 * 1) {
      scrollkey = 'a';
    } else if (ev.center.x < window.innerWidth / 6 * 2) {
      scrollkey = 'b';
    } else if (ev.center.x < window.innerWidth / 6 * 3) {
      scrollkey = 'c';
    } else if (ev.center.x < window.innerWidth / 6 * 4) {
      scrollkey = 'd';
    } else if (ev.center.x < window.innerWidth / 6 * 5) {
      scrollkey = 'e';
    } else if (ev.center.x < window.innerWidth / 6 * 6) {
      scrollkey = 'f';
    }
    scrollactive = false;
    if (scroll[scrollkey] != undefined) {
      //try 'get'
      console.log('getting scroll...');
      Promise.all([
        new Promise(function(resolve, reject) {
          socket.emit('scroll-get', scrollkey, function(response) {
            console.log(response);
            resolve(response);
          });
        })
      ]).then(function(response) {
        if (response[0] == true) {
          scrollactive = true;
          scrollold = scroll[scrollkey].value;
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
      } else if (scrollkey == 'e') {
        project5.activate();
        project5.view.center = [
          project5.view.center.x,
          scroll[scrollkey].value
        ];
      } else if (scrollkey == 'f') {
        project6.activate();
        project6.view.center = [
          project6.view.center.x,
          scroll[scrollkey].value
        ];
      }
    }
  });
  hm.on('panend', function(ev) {
    if (scrollactive == true) {
      scroll[scrollkey].value = scrollold - ev.deltaY;
      scroll[scrollkey].islocked = false;
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
      } else if (scrollkey == 'e') {
        project5.activate();
        project5.view.center = [
          project5.view.center.x,
          scroll[scrollkey].value
        ];
      } else if (scrollkey == 'f') {
        project6.activate();
        project6.view.center = [
          project6.view.center.x,
          scroll[scrollkey].value
        ];
      }
      //release my holding
      scrollactive = false;
      patterns[scrollkey].forEach(function(item) {
        if (scrollkey == 'a') {
          item.strokeColor = new Color('black');
        } else {
          item.fillColor = new Color('black');
        }
      });
    }
  });

});