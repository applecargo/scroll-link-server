//paperscript (paperjs)

//'index' page

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
    var nscreen = 4;
    var screens = [];
    var screen_names = {};
    screen_names['home'] = 1;
    screen_names['intro'] = 2;
    screen_names['scrollers'] = 3;
    screen_names['buttons'] = 4;
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
    c_page_prev.fillColor = 'white';
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
    c_page_next.fillColor = 'white';
    c_page_next.onClick = function() {
      // this._socket.emit('page', {
      //   name: getScreenNameNext()
      // });
      nextScreen();
    };

    //screen #1
    changeScreen(1);
    new Path.Rectangle([0, 0], vs).fillColor = '#999'; //

    //
    phonehand.addTo(project);
    phonehand.scale(vsw / 1.5);
    phonehand.position = view.center;
    phonehand.position.y -= vssh;

    //
    anext.addTo(project);
    anext.scale(vsw / 4);
    anext.position = phonehand.bounds.bottomRight;
    anext.onFrame = function(event) {
      if (event.count % 30 == 0) {
        this.fillColor = new Color({
          hue: getRandom(100, 360),
          saturation: 1,
          brightness: 1
        });
      }
    };
    anext.onClick = function(event) {
      nextScreen(); //go next screen.
    };

    //screen #2
    changeScreen(2);
    new Path.Rectangle([0, 0], vs).fillColor = '#999';

    //for conductor
    var c_clap = new Group();
    c_clap.addChild(new Path.Rectangle({
      point: view.center,
      size: [vssw*3, vssw*3],
    }));
    c_clap.addChild(new PointText({
      content: "clap!",
      point: c_clap.bounds.topRight,
      fontWeight: 'bold',
      fontSize: '3em'
    }));
    c_clap.translate([-vssw*2, -vssw*2]);
    c_clap._socket = socket;
    c_clap._clapping = false;
    c_clap._clapper = undefined;
    c_clap.fillColor = 'skyblue';
    c_clap.onClick = function() {
      //
      if (this._clapping == false) {
        this._clapping = true;
        this._socket.emit('clap', {
          name: 'clap',
          action: 'start'
        });
        this._clapper = setInterval(function() {
          this._socket.emit('clap', {
            name: 'clap',
            action: 'start'
          });
        }.bind(this), 2000);
        this.fillColor = 'red';
      } else {
        if (this._clapping == true) {
          this._clapping = false;
          clearInterval(this._clapper);
        }
        this.fillColor = 'skyblue';
      }
    };

    // //
    // //TODO: info text.
    // new PointText({
    //   content: "네트워크 테스트!",
    //   point: view.center + [-vssw*3, -vssw*2],
    //   fontWeight: 'bold',
    //   fontSize: '2em',
    //   fillColor: 'gold'
    // });
    // new PointText({
    //   content: "사운드 테스트!",
    //   point: view.center + [-vssw*3, vssw*0],
    //   fontWeight: 'bold',
    //   fontSize: '2em',
    //   fillColor: 'pink'
    // });
    // new PointText({
    //   content: "동그라미 터치!",
    //   point: view.center + [-vssw*3, vssw*2],
    //   fontWeight: 'bold',
    //   fontSize: '2em',
    //   fillColor: 'red'
    // });
    // var aa = new Path.Circle({
    //   center: view.center,
    //   radius: vsw / 4,
    //   fillColor: 'white',
    // });
    // aa.onClick = function() {
    //   //clap
    //   clap.start();
    // };
    // aa.opacity = 0.5;

    //screen #3
    changeScreen(3);
    new Path.Rectangle([0, 0], vs).fillColor = '#999';

    //
    new Group(
      [
        new Path.Circle({
          center: view.center,
          radius: vsw / 2,
          fillColor: 'gold',
        }),
        new PointText({
          content: "8",
          point: view.center,
          fillColor: 'white',
          fontWeight: 'bold',
          fontSize: '5em',
        })
      ]
    ).onClick = function() {
      //go to the page
      window.location.href = "./scroll6.html";
    };

    //screen #4
    changeScreen(4);
    new Path.Rectangle([0, 0], vs).fillColor = '#999';

    //
    new Group(
      [
        new Path.Circle({
          center: view.center,
          radius: vsw / 2,
          fillColor: 'purple',
        }),
        new Path.Circle({
          center: view.center,
          radius: vsw / 4,
          fillColor: 'white',
        })
      ]
    ).onClick = function() {
      //go to the page
      window.location.href = "./buttons.html";
    };

    //
    changeScreen(1);

    //network event handlers

    //event: 'clap'
    socket.on('clap', function(msg) {
      if (msg.name == 'clap') {
        if (msg.action == 'start') {
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
