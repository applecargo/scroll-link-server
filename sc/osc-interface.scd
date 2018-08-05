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
