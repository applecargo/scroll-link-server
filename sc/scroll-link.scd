/*
	*
	* a supercollider sound & music server for scroll-link-server
	*
	*
	* dhy @ dianaband @ 2018. 07. 28.
	*
*/

//// NOTES


/*

    * THE SC/EMACS KEYS

    * line eval : C-c C-c
    * block eval : C-M-x
	* help gui : C-c h
    * stop all : C-c C-s
	* server boot : C-c C-p b
	* server rec start : C-c C-p r r
	* server rec stop : C-c C-p r s
	* server rec pause : C-c C-p r p

*/



/*

	* sc basics!!

	(1) sclang allows 'new' being omitted.

	so.. every XXX(...) can be a XXX.new(...)
	so.. SynthDef() --> SynthDef.new(...)
	so.. OSCFunc() --> OSCFunc.new(...)
	this knowledge can clear out where to look into, when we refer the doc

	(2) the definitive behaviour of 'eval region' -> what exactly is the region

	in the doc. condition of being a region is..
	'(' present in the line start. and nothing else
	then, until the closing matched brackets.
	that is a region. so eval-region possible.

	these 2 are so basic. but basic is what i need. for sure.

*/


/*

	* SynthDef basics..


	why I had to use Out.ar(...) to get sounds? when it was fine with simpler {(func.)}.play..?

	--> "When you use Function-play an Out UGen is in fact created for you
	if you do not explicitly create one. The default bus index for this Out UGen is 0."
	--> http://doc.sccode.org/Tutorials/Getting-Started/10-SynthDefs-and-Synths.html
	--> so, it was in fact, being created automatically.
	without it.. there's no sound.
	Out is like dac~ in Pd.. so it is very clear why no sound?.. cause it is same as 'having no dac~ in Pd'.

*/


/*
	* interfacing OSC over network

	(receiving from osc-js + very basic OscFunc usage)
*/
//check ALL open ports of this SC
thisProcess.openPorts;

//show ALL messages!!
// --> before running trace(true), quiting the server first is advisable..
//     there's already LOTS of messages between sclang and scsynth.. it's very crowded.
OSCFunc.trace(true); // turn on
OSCFunc.trace(false); // turn off

//srdID is important!
// --> ip addr. of the machine that sends out OSC msgs. to this SC.
n = NetAddr.new("127.0.0.1", 57121);
//from the scdoc
// --> srcID
//     "An optional instance of NetAddr indicating the IP address of the sender.
//      If set this object will only respond to messages from that source."
//
//using OSCFunc to receive a specific message from a specific sender
OSCFunc({|msg, time, addr, recvPort| [msg, time, addr, recvPort].postln;}, '/odom',	n);

/*

	* OSCdef basics..

	OSCdef is better than OSCFunc,
	because it will be registered in global dictionary
	+
	and basically it will be replaced everytime you re-def.

*/
//print list of OSCdefs
OSCdef.all
//when created, it is enabled. u can disable.
OSCdef(\tball_osc).disable;
//then, enable again.
OSCdef(\tball_osc).enable;
//unregister from the dictionary
OSCdef(\tball_osc).free;
//'clear'... what's the point of this method, while we have 'free' and/or 'disable' already?
//OSCdef(\tball_osc).clear;




//// quoted sounds / examples / collections

(
{   var m0, m1, m2, m3, m4, d, k, t;
    k = MouseX.kr(0.5, 100, 1);
    d = MouseY.kr(0.0001, 0.01, 1);
    t = Dust.ar(2);
    m0 = Spring.ar(ToggleFF.ar(t), 1 * k, 0.01);
    m1 = Spring.ar(m0, 0.5 * k, d);
    m2 = Spring.ar(m0, 0.6 * k, d);
    m3 = Spring.ar([m1,m2], 0.4 * k, d);
    m4 = Spring.ar(m3 - m1 + m2, 0.1 * k, d);
    CombL.ar(t, 0.1, LinLin.ar(m4, -10, 10, 1/8000, 1/100), 12)

}.play;
)


(
SynthDef(\tball, {
	Out.ar([0, 1], {
		var t, sf;
		sf = K2A.ar(MouseX.kr > 0.5) > 0;
		t = TBall.ar(sf, MouseY.kr(0.01, 1.0, 1), 0.01);
		Ringz.ar(t * 10, 1200, 0.1)
	})
}).play
)

~notes = SynthDef(\notes, {
	var a;
	a = Scale(
		#[0, 2, 4, 5, 7, 9, 10],
		12,
		Tuning([0, 0.8, 2.1, 3, 4.05, 5.2, 6, 6.75, 8.3, 9, 10.08, 11.5]),
		"Custom"
	);
	a = Scale.ionian;
	p = Pbind(
		\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0, \rest], inf),
		\scale, Pfunc({ a }, inf),
		\dur, 0.25
	).play
});


/* ______scroll-link-sound-set______ */


//// trial #1


(
//// (set #1 : physical ball w/ gravity changing)

//a syncthdef
//a syncthdef + freeverb ('more rough marble sound')
//grav : 0.01 ~ 1
//damp : 0.01
~tball = SynthDef(\tball, {|grav=1, damp=0.01|
	Out.ar([0, 1], {
		var t, a;
		t = TBall.ar(Pulse.ar(0.1, 0.5), grav, damp);
		// a = Ringz.ar(t * 10, 1200, 0.1);
		a = Resonz.ar(t * 500, 120, 10);
		FreeVerb.ar(a, 0.5,	0.5, 0.7) ! 2;
	})
}).play;

//// (set #2 : some pluck w/ 'coef' changing)

//a syncthdef
~pluck = SynthDef(\notes, {|coef=0.25|
	Out.ar([0, 1], {
		Pluck.ar(
			WhiteNoise.ar(0.1),
			Impulse.kr(2),
			440.reciprocal,
			440.reciprocal,
			10,
			coef:coef,
			mul:3
		)
	})
}).play;

//osc controller
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
	},'/odom', n
);
)



//// trial #1.5

////NOTE:
//    a failed trial was...
//    using 2 separate synths..
//    and synth 1 will modify a global parameter.
//    and this change taking place inside of Synth #2..
//    but didn't work properly.. couldn't achieve at all. :(
//    so, i thought.. well. simply put everything into 1 synth. see below trial #2
//


//// trial #2

//linked 2 synth 1 --> ball triggers pluck
//Demand/Dseq will give tonic melodies to pluck
(
~tball = SynthDef(\tball, {|grav=1, damp=0.01, coef=0.25|
	Out.ar([0, 1], {
		var t, a, b, f;
		t = TBall.ar(Pulse.ar(0.1, 0.5), grav, damp);
		// a = Ringz.ar(t * 10, 1200, 0.1);
		// // a = Resonz.ar(t * 500, 120, 10);
		// b = FreeVerb.ar(a, 0.5,	0.5, 0.7) ! 2;
		Pluck.ar(
			WhiteNoise.ar(0.1),
			t,
			Demand.kr(
				T2K.kr(t),
				0,
				Dseq(
					[60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 74, 72, 71, 69, 67, 65, 64, 62, 60].midicps.reciprocal,
					inf
				)
			),
			Demand.kr(
				T2K.kr(t),
				0,
				Dseq(
					[60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 74, 72, 71, 69, 67, 65, 64, 62, 60].midicps.reciprocal,
					inf
				)
			),
			10,
			coef:coef,
			mul:3
		) ! 2
	})
}).play;

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
				~tball.set(\coef, coef);
				// ~pluck.set(\coef, coef);
			}
		);
	},'/odom', n
);
)
