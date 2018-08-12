(
OSCdef(\osc_dispatcher,
	{ |msg|
		var target = msg[1];
		var value = msg[2];
		//factors
		var grav;
		var dectime;
		msg.postln;
		//
		switch(target,
			\a, {
				grav = (value.abs * 0.001);
				("grav -> " + grav).postln;
				Ndef(\ball).set(\grav, grav);
			},
			\b, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\c, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\d, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\e, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\f, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\g, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\h, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\i, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			},
			\j, {
				dectime = (value.abs * 0.0001);
				("dectime -> " + dectime).postln;
				Ndef(\ball).set(\dectime, dectime);
			}
		);
	},'/scroll'
);
)

//some simple/minimal test codes

//getting a full trace
OSCFunc.trace(true);
OSCFunc.trace(false);

//just post what we are getting.
(
OSCdef(\osc_dispatcher,
	{ |msg|
		msg.postln;
	}
	,'/scroll'
);
)
