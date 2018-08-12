window.onload = function() {

  //graphics - paperjs

  paper.install(window);

  paper.setup(document.getElementById('paperjs'));

  //fill-up a rectangular area with circles (automatically)
  //visual property of the circles changes. color or strokeWidth or dashed pattern.. or anything.
  var w = 25
  for (var row = 10; row >= 0; row--) {
    for (var col = 0; col < 10; col++) {
      var c;
      if (row % 2 == 0) {
        c = new Path.Circle({
          center: [50 + col * 100, 50 + row * 65],
          radius: 50,
        });
      }
      else {
        c = new Path.Circle({
          center: [100 + col * 100, 50 + row * 65],
          radius: 50,
        });
      }
      c.style = {
        strokeWidth: w,
        strokeColor: 'black',
        fillColor: 'white'
      }
    }
    w = w * 0.9;
  }
}
