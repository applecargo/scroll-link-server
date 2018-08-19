//paperscript (paperjs)

//'buttons' page

$(document).ready(function() {

  //common metrics
  var vs = view.size;
  var vsw = vs.width;
  var vsh = vs.height;
  var vss = view.size / 10;
  var vssw = vss.width;
  var vssh = vss.height;

  //pre-load resources
  Promise.all([
    //
    RasterImport_size1('./imgs/phonehand.png'),
    SVGImport_size1('./imgs/arrow-circle-right.svg'),
    SVGImport_size1('./imgs/arrow-circle-left.svg'),
    SVGImport_size1('./imgs/hand-point-right-regular.svg'),
    //
    AudioImport("./audio/clap@2/" + ("0" + getRandomInt(1, 2)).slice(-2) + ".mp3"),
    //
  ]).then(function(imports) {
    //
    var phonehand = imports[0];
    var anext = imports[1];
    var aprev = imports[2];
    var hand = imports[3];
    var clap = imports[4];

    //screen changer
    var nscreen = 3;
    var screens = [];
    var screen_names = {};
    screen_names['select'] = 1;
    screen_names['keyboard'] = 2;
    screen_names['buttons'] = 3;
    var curscreen;
    for (var idx = 0; idx < nscreen; idx++) {
      screens.push(new Layer());
    }

    function changeScreen(page) {
      //
      if (page < 1) page = 1;
      if (page > nscreen) page = nscreen;
      curscreen = page;
      for (var idx = 0; idx < nscreen; idx++) {
        if (idx == page - 1) {
          screens[idx].bringToFront();
          top.bringToFront();
          $('.objstring').eq(idx).css('z-index', 1);
        } else {
          screens[idx].sendToBack();
          $('.objstring').eq(idx).css('z-index', -1);
        }
      }
    }

    function nextScreen() {
      if (curscreen + 1 <= nscreen) {
        curscreen++;
        changeScreen(curscreen);
      }
    }

    function prevScreen() {
      if (curscreen - 1 > 0) {
        curscreen--;
        changeScreen(curscreen);
      }
    }

    function changeScreenByName(pagename) {
      changeScreen(screen_names[pagename]);
    }

    function getScreenNameNext() {
      if (curscreen + 1 <= nscreen) {
        return Object.keys(screen_names)[curscreen + 1 - 1];
      } else {
        return Object.keys(screen_names)[curscreen - 1];
      }
    }

    function getScreenNamePrev() {
      if (curscreen - 1 > 0) {
        return Object.keys(screen_names)[curscreen - 1 - 1];
      } else {
        return Object.keys(screen_names)[curscreen - 1];
      }
    }

    //top layer
    var top = new Layer(); // new Layer() will be automatically activated at the moment.

    //networking - socket.io
    var socket = io('http://192.168.1.105:8080');
    //var socket = io('https://choir.run');

    //net. connection marker
    var netstat = new Path.Circle({
      center: view.bounds.topRight + [-vssw / 2, +vssw / 2],
      radius: vssw / 4,
      fillColor: 'hotpink',
      strokeWidth: 2,
      strokeColor: 'gray',
      dashArray: [4, 4],
      onFrame: function(event) {
        this.rotate(1);
      }
    });
    netstat.fillColor.alpha = 0;

    //
    socket.on('connect', function() {
      console.log("i' m connected!");
      top.activate();
      netstat.fillColor.alpha = 1;
      socket.on('disconnect', function() {
        console.log("i' m disconnected!");
        top.activate();
        netstat.fillColor.alpha = 0;
      });
    });

    //for conductor - to direct everyone's page
    var c_page_prev = new Group();
    //
    c_page_prev.addChild(new Path.Rectangle({
      point: [0, 0],
      size: [vssw*2, vssw*2],
    }));
    c_page_prev.addChild(new PointText({
      content: "prev",
      point: c_page_prev.bounds.topLeft + [0, -5],
      fontWeight: 'bold',
      fontSize: '1em'
    }));
    c_page_prev.translate([0, +vssw * 2]);
    c_page_prev._socket = socket;
    c_page_prev.fillColor = 'pink';
    c_page_prev.onClick = function() {
      // this._socket.emit('page', {
      //   name: getScreenNamePrev()
      // });
      prevScreen();
    };

    var c_page_next = new Group();
    c_page_next.addChild(new Path.Rectangle({
      point: [0, 0],
      size: [vssw*2, vssw*2],
    }));
    c_page_next.addChild(new PointText({
      content: "next",
      point: c_page_next.bounds.topLeft + [0, -5],
      fontWeight: 'bold',
      fontSize: '1em'
    }));
    c_page_next.translate([vsw - vssw*2, +vssw * 2]);
    c_page_next._socket = socket;
    c_page_next.fillColor = 'pink';
    c_page_next.onClick = function() {
      // this._socket.emit('page', {
      //   name: getScreenNameNext()
      // });
      nextScreen();
    };

    //screen #1
    changeScreen(1);
    new Path.Rectangle([0, 0], vs).fillColor = '#3333ff'; //;

    //voice list
    var voices = {
      '너': 0,
      '곰곰': 1,
      '레나': 2,
      '은솔': 3,
      '파인': 4,
      '심심이': 5,
      'ㅇㅅㅁ': 6,
      '동네마구': 7,
      '파인트리': 8,
      '금요일오전': 9,
      'papyrus78': 10,
      'ㅈㄹ': 11,
      '원정': 12,
      'ㄱㄷ': 13,
      'ㅎㅁㅁ': 14,
      'ㅇㅅ': 15,
      'ㅂㄱ': 16,
      'ㄷㅋㅅ': 17,
      '당당': 18,
      'ㅈㅇㅈ': 19,
    }

    //voice select buttons
    var voice_selected = 0;
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 4; col++) {
        var idx = row*4 + col;
        var c = new Path.Circle({
          center: [col*vssw*2 + vssw*2, row*vssw*2 + vssw*6],
          radius: vssw * 0.8,
          fillColor: new Color({
            hue: getRandom(0, 180),
            saturation: 1,
            brightness: 1
          }),
          _idx: idx,
          onClick: function () {
            voice_selected = this._idx;
            console.log(voice_selected);
            //next screen.
            changeScreen(2);
          }
        });
        new PointText({
          point: c.bounds.topLeft + [0, -5],
          content: Object.keys(voices)[idx],
          fontSize: '1em',
          fontWeight: 'bold',
          fillColor: c.fillColor
        });
      }
    }

    //screen #2 - keyboard
    changeScreen(2);
    new Path.Rectangle([0, 0], vs).fillColor = 'gold';

    //white keys
    var keysize = vssw*1;
    for (var idx = 0; idx < 10; idx++) {
      new Path.Rectangle({
        point: [vssw*2.5, (keysize + 5) * idx + vssw * 3.5],
        size: [vssw*5, keysize],
        fillColor: 'white',
        _restfill: 'white',
        _activefill: new Color({
          hue: getRandom(0, 360),
          saturation: 1,
          brightness: 1
        }),
        _socket: socket,
        _idx: 10 - idx,
        onMouseDown: function () {
          this.fillColor = this._activefill;
          var msg = {id: voice_selected, key: this._idx};
          console.log(msg);
          this._socket.emit('voice', msg);
        },
        onMouseUp: function () {
          this.fillColor = this._restfill;
        }
      });
    }
    //black keys
    var idx = 0
    var keysize2 = vssw*0.9;
    for (; idx < 2; idx++) {
      new Path.Rectangle({
        point: [vssw*2.0 + vssw * -0.1, (keysize + 7) * idx + vssw * 3.5 + keysize / 2],
        size: [vssw*3, keysize2],
        fillColor: '#444'
      });
    }
    for (; idx < 5; idx++) {
      new Path.Rectangle({
        point: [vssw*2.0 + vssw * -0.1, (keysize + 7) * idx + vssw * 3.5 + keysize / 2 + keysize],
        size: [vssw*3, keysize2],
        fillColor: '#444'
      });
    }
    for (; idx < 7; idx++) {
      new Path.Rectangle({
        point: [vssw*2.0 + vssw * -0.1, (keysize + 7) * idx + vssw * 3.5 + keysize / 2 + keysize * 2],
        size: [vssw*3, keysize2],
        fillColor: '#444'
      });
    }

    //screen #3 - buttons
    changeScreen(3);
    new Path.Rectangle([0, 0], vs).fillColor = '#2a8e82'; //atlantic green;

    //button list
    var buttons = {
      'a': 0,
      'b': 1,
      'c': 2,
      'd': 3,
      'e': 4,
      'f': 5,
      'g': 6,
      'h': 7
    }

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        var idx = row*3 + col;
        if (idx == 8) break;
        var c = new Path.Circle({
          center: [col*vssw*3 + vssw*2, row*vssw*3 + vssw*6],
          radius: vssw * 1.2,
          fillColor: new Color({
            hue: getRandom(0, 180),
            saturation: 1,
            brightness: 1
          }),
          _idx: idx,
          _socket: socket,
          onMouseDown: function () {
            console.log(Object.keys(buttons)[this._idx] + " pressed");
            this._socket.emit('sound', {
              name: Object.keys(buttons)[this._idx],
              action: 'start'
            });
          },
          onMouseUp: function () {
            console.log(Object.keys(buttons)[this._idx] + " released");
            this._socket.emit('sound', {
              name: Object.keys(buttons)[this._idx],
              action: 'stop'
            });
          }
        });
        new PointText({
          point: c.bounds.topLeft + [0, -5],
          content: Object.keys(buttons)[idx],
          fontSize: '2em',
          fontWeight: 'bold',
          fillColor: c.fillColor
        });
      }
    }

    //home
    changeScreen(1);

    //network event handlers

    //event: 'sound'
    socket.on('sound', function(sound) {
      if (sound.name == 'clap') {
        if (sound.action == 'start') {
          clap.start();
        }
      }
    });

    //event: 'page'
    socket.on('page', function(page) {
      changeScreenByName(page.name);
    });

  });

});
