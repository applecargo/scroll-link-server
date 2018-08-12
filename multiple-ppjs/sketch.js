$(document).ready(function() {

  // paper.install(window);

  // var project1;
  paper.setup(document.getElementById('paperjs1'));
  // project1 = project;
  var r1 = new paper.Path.Rectangle({
    point: [50, 50],
    size: [25, 20],
    fillColor: 'red'
  });

  // paper.setup(document.getElementById('paperjs2'));
  // var r2 = new Path.Rectangle({
  //   point: [50, 50],
  //   size: [25, 20],
  //   fillColor: 'blue'
  // });
  // view.onFrame = function(event) {
  //   r2.rotate(1);
  // }

  // project1.activate();
  // var r3 = new Path.Rectangle({
  //   point: [50, 50],
  //   size: [25, 20],
  //   fillColor: 'green'
  // });
  // project1.view.onFrame = function(event) {
  //   r1.rotate(1.2);
  //   r3.rotate(1);
  // }

});
