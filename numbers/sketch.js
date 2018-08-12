//'scroll' status array
var scroll = {};

//jquery enabled
$(document).ready(function() {

  //paper.js
  paper.install(window);

  //canvas #1
  paper.setup(document.getElementById('paperjs1'));
  var project1 = project;

  //world(scene) size
  var SCENE_W = view.size.width;
  var SCENE_H = 5000;

  //fill the world with simply 'rectangle's
  var step = 30;
  var n = SCENE_H / step;
  for (var idx = 0; idx < n; idx++) {
    var r = new Path.Line({
      from: [-20 * idx, step * idx],
      to: [2 * step * idx, 0],
      strokeWidth: idx / 10,
      dashArray: [idx, 3],
      strokeColor: 'black',
    });
    r.rotate(-0.5 * idx);
  }

  //canvas #2
  paper.setup(document.getElementById('paperjs2'));
  var project2 = project;

  //world(scene) size
  SCENE_W = view.size.width;
  SCENE_H = 5000;
  step = 100;
  n = SCENE_H / step;

  //fill the world with simply 'rectangle's
  for (var idx = 0; idx < n; idx++) {
    var r = new Shape.Rectangle({
      point: [SCENE_W / 2, step * idx],
      size: [idx + 2, idx + 2],
      fillColor: 'black',
    });
  }

  //networking - socket.io
  var socket = io('http://192.168.1.105:8080');
  socket.on('connect', function() {
    console.log("i' m connected!");
  });

  //scroll data update
  socket.on('scroll', function(msg) {

    //update scroll status
    scroll[msg.key] = {
      value: msg.data.value,
      islocked: msg.data.islocked
    };

    //DEBUG: show on the page
    var text =
      "key : " + msg.key + "<br/>" +
      "value : " + msg.data.value + "<br/>" +
      "islocked : " + msg.data.islocked;
    $('#objstring').html(text);
    //
    //view update
    //view.center but MUST be updated with a Point! otherwise, it doesn't work.. :(

    //TODO: so we need to have multiple views.. multitple paperjs for multiple canvas.
    //DEBUG: for now, we only have 1 view 1 canvas 1 scroll named 'you'
    if (msg.key == 'you') {
      project1.activate();
      //NOTE: writing to view.center is an expensive operation! (re-draw whole screen even though nothing changed!)
      project1.view.center = [
        project1.view.center.x,
        scroll[msg.key].value
      ];
    } else if (msg.key == 'abc') {
      project2.activate();
      //NOTE: writing to view.center is an expensive operation! (re-draw whole screen even though nothing changed!)
      project2.view.center = [
        project2.view.center.x,
        scroll[msg.key].value
      ];
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
  //scroll start
  var scrollactive = false;
  var scrollold = 0;
  var scrollkey = ""; //TODO: i think at last, HM (also Paperjs) should be attached specific canvas element and the codes to be independant!
  hm.on('panstart', function(ev) {
    switch (Math.floor(ev.center.x / window.innerWidth * 2)) {
      case 0:
        scrollkey = 'you';
        break;
      case 1:
        scrollkey = 'abc';
        break;
      // case 2:
      //   scrollkey = 'noise'
      //   break;
      default:
        console.log('unknown key!'); //error!
    }
    //
    //TODO: if you scroll to early before getting init values.. following happens.
    //      actually.. why not be more guarantee to get connection + update first..
    //      Promise.. or socket.io callback etc.
    //
    if (scroll[scrollkey] != undefined) {
      //claim the scroller
      throttled_send(scrollkey, scroll[scrollkey].value, true);
      // //TODO: check server's ACK. (server will block others to get it.)
      // socket.emit('scroll-get', function (answer) {
      //   if (answer == true) {
      //     //okay, acquired.
      //     scrollactive = true;
      //     scrollold = scroll[scrollkey].value;
      //   } else {
      //     //well.. next time.
      //     scrollactive = false;
      //     console.log('the key is locked now.');
      //   }
      // });
      //DEBUG: now simply get it.
      scrollactive = true;
      scrollold = scroll[scrollkey].value;
    }
  });
  //momentary scroll position while touching.
  hm.on('panmove', function(ev) {
    if (scrollactive == true) {
      scroll[scrollkey].value = scrollold + ev.deltaY;
      //limit scrolling at the edge!
      //
      //TODO: if you do scrolling with accel. velocity. then this can be vel = 0.
      //      then bumping effect happens. which is good to inform people that here is the ending.
      //
      if (scroll[scrollkey].value < 0) scroll[scrollkey].value = 0;
      if (scroll[scrollkey].value > SCENE_H) scroll[scrollkey].value = SCENE_H;
      throttled_send(scrollkey, scroll[scrollkey].value, true);
      // scene scroll
      if (scrollkey == 'you') {
        project1.activate();
        project1.view.center = [
          project1.view.center.x,
          scroll[scrollkey].value
        ];
        console.log(scrollkey);
      } else if (scrollkey == 'abc') {
        project2.activate();
        project2.view.center = [
          project2.view.center.x,
          scroll[scrollkey].value
        ];
        console.log(scrollkey);
      }
      //NOTE: writing to view.center is an expensive operation! (re-draw whole screen even though nothing changed!)
    }
  });
  //accumulating scroll position at the moment of the end of panning action -> thus, make scroll range bigger than screen height.
  hm.on('panend', function(ev) {
    if (scrollactive == true) {
      //scroll[scrollkey].value = scrollold - ev.deltaY;
      scroll[scrollkey].value = scrollold + ev.deltaY;
      //limit scrolling at the edge!
      if (scroll[scrollkey].value < 0) scroll[scrollkey].value = 0;
      if (scroll[scrollkey].value > SCENE_H) scroll[scrollkey].value = SCENE_H;
      throttled_send(scrollkey, scroll[scrollkey].value, false);
      // scene scroll
      if (scrollkey == 'you') {
        project1.activate();
      } else if (scrollkey == 'abc') {
        project2.activate();
      }
      //NOTE: writing to view.center is an expensive operation! (re-draw whole screen even though nothing changed!)
      view.center = [
        view.center.x,
        scroll[scrollkey].value
      ];
      //release my holding
      scrollactive = false;
    }
  });

  //TODO:
  //    - limit scroll range.
  //    - some visual feedback for the user when they've reached to the edges
  //    - cpu demanding. -> lodash/throttle or.. hammerjs's api to throttle the events.. or anyway solve the prob.

});
//
//
//
//
// // //p5 canvas setup
// // //using p5.play.js (virtual camera) --> http://molleindustria.github.io/p5.play/
// // var SCENE_W = window.innerWidth;
// // //var SCENE_H = window.innerHeight * 2; // 2 times longer scrollable world.
// // var SCENE_H = 5000; // 2 times longer scrollable world.
// // var step = 100;
// // var n = SCENE_H / step;
// // new p5(function(p) {
// //   p.setup = function() {
// //     //p.createCanvas(window.innerWidth, window.innerHeight, p.WEBGL);
// //     p.createCanvas(window.innerWidth, window.innerHeight);
// //   };
// //   p.draw = function() {
// //     p.background(125);
// //     p.fill(0);
// //     for (var idx = 0; idx < n; idx++) {
// //       p.rect(p.width / 2, step * idx, idx + 2, idx + 2);
// //     }
// //     if (scroll['you'] != undefined) {
// //       p.camera.position.y = scroll['you'].value;
// //     }
// //   };
// // });
//
// // //two.js
// // var SCENE_W = window.innerWidth;
// // var SCENE_H = 5000;
// // //
// // var elem = document.getElementById('twojs');
// // var params = { width: 285, height: 200 };
// // var two = new Two(params).appendTo(elem);
// // //
// // var rect = two.makeRectangle(213, 100, 100, 100);
// // rect.fill = 'rgb(0, 200, 255)';
// // rect.opacity = 0.75;
// // rect.noStroke();
// // //
// // two.update();
