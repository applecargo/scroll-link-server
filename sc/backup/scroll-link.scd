/*
	*
	* a supercollider sound & music server for scroll-link-server
	*
	* dhy @ dianaband @ 2018. 07. 28.
	*
*/


s.boot;
s.queryAllNodes(true);
s.plotTree;
s.meter;

//sessions

(
Pbind(
    \instrument, \piano,
    \delta, 1,
    \dur, 3,
    \degree, Pseq([1,3,5], inf),
    \out, 20,
).play;
)

Synth.tail(1, \piano_soundboard);
t = Synth(\piano)

(
a = Synth(\tball);
b = Synth.after(a, \ring, [\mul, 100]);
c = Synth.after(b, \verb);
//c.set(\room, 0.9);
//c.set(\room, 1);
c.set(\room, 0.1);
//c.set(\damp, 0.1);
c.set(\damp, 0.9);
//c.set(\mix, 0);
c.set(\mix, 0.7);
)

a.set(\grav, 0.5);
a.set(\damp, 0.05);
b.set(\mul, 300);
b.free;
b = Synth.after(a, \reson, [\mul, 100]);
b.set(\mul, 2000);
Synth.
s.queryAllNodes


OSCdef(\osc_dispatcher,
	{ |msg|
		var target = msg[1];
		var odom = msg[2];
		//factors
		var grav;
		var coef;
		//
		switch(target,
			0, { // 0: left
				grav = (odom.abs * 0.001);
				("grav -> " + grav).postln;
				~tball.set(\grav, grav);
			},
			1, { // 1: right
				coef = (odom.abs * 0.0001);
				("coef -> " + coef).postln;
				~pluck.set(\coef, coef);
			}
		);
	},'/odom', NetAddr.new("127.0.0.1", 57121)
);
)
