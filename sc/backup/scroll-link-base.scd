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


(
SynthDef(\help_oteypiano, { |out=0, freq=440, gate=1, amp=0.5, rho=1|
    var son = OteyPiano.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add;
)

//Use it.
(
Pbind(
    \instrument, \help_oteypiano,
    \delta, 1,
    \dur, Pseq([3,0.2,2,3], inf),
    \degree, Pseq([1,3,5,9], inf),
    \rho, Pwhite(0.1,3) //comment this line to get standard sound
).play;
)

//Define pluck synthdef
(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

//Use it.
(
a = Scale.new(
    #[0, 1, 3, 5, 7, 8, 10],
    12,
    Tuning.new([0, 0.75, 2, 3.5, 4, 5, 6, 7, 8, 9, 10, 11]),
    "Custom"
);

Pbind(
    \instrument, \help_dwgplucked,
    \scale ,a,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*0.25,inf),
    \dur , 2,
    \degree, Pseq([1,8,8,8,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
    \c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    \pan , Pwhite(-1,1),
).play;
)


{(NTube.ar(WhiteNoise.ar*SinOsc.ar(0.5),`[0.97,1.0,1.0,1.0,0.97],`[0.5,MouseY.kr(-1.0,1.0),0.2],`([0.01,0.02,0.01,0.005]*MouseX.kr(0.01,1.0)))*0.1).dup}.play


//Define piano synthdef and soundboard
(
SynthDef(\help_oteypianostring, { |out=0, freq=440,gate=1, amp=0.5,rho=1|
    var son = OteyPianoStrings.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
    Out.ar(out, Pan2.ar(son * 1, LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add;

SynthDef(\piano_soundboard,{
    var audio = In.ar([20, 21], 2);
    audio = OteySoundBoard.ar(audio);
    Out.ar(0,audio);
}).add
)

//start soundboard effect
Synth.tail(1,\piano_soundboard);

//Use it.
(
Pbind(
    \instrument, \help_oteypianostring,
    \delta, 1,
    \dur, Pseq([3,0.2,2,3], inf),
    \degree, Pseq([1,3,5,12,2,6,8], inf),
    \out, 20,
).play;
)


//Define bow synthdef
(
SynthDef(\helpStkbowed,{arg out=0,freq=220,gate=1,amp=1,bowpressure = 64, bowposition = 17, vibfreq=50, vibgain=1, loudness=128;
    var sig,env;
    env = EnvGen.kr(Env.asr(0,1,0.1),gate,doneAction:2);
    sig = StkInst.ar(Stk.at("Bowed"),freq, gate, amp, 0.5,[2,bowpressure,4,bowposition,11,vibfreq,1,vibgain,128,loudness])*env;
    Out.ar(out, sig.dup);
}).add;
)

//Use it.
(

Pbind(
    \instrument, \helpStkbowed,
    \dur , 0.25,
    \degree, Pseq([1,5,7+3], inf),
    \amp , Pseq([0.9,0.7,0.5],inf),
    \bowposition , Pseq([10,20,30,40,50,60],inf)
).play;
)

play

{DiodeRingMod.ar(SinOsc.ar(18000 * ([1, 1.1, 1.2] * SinOsc.ar(200).range(1, 2))), SinOsc.ar(100 * [0.75, 1, 0.5])).sum * 0.2 * LFPulse.ar(10.3 * 1/6, 0, 0.02) * 0.1}.play

play

{DiodeRingMod.ar(SinOsc.ar(1800 * ([1, 1.1, 1.2] * SinOsc.ar(200).range(1, 2))), SinOsc.ar(100 * [0.75, 1, 0.5])).sum * 0.2 * LFPulse.ar(10.3 * LFPulse.ar(10.3).range(1/6, 1/2), 0, 0.02) * 0.1}.play


{DiodeRingMod.ar(SinOsc.ar(400 * ([1, 1.1, 1.2] * SinOsc.ar(200).range(1, 2))), SinOsc.ar(100 * [0.75, 1, 0.5])).sum * 0.2 * LFPulse.ar(10.3 * 1/32, 0, 0.2) * 0.1}.play
s.sendMsg(\n_free, 2809)

Dbufrd

s.queryAllNodes(true)
s.makeGui


//most basic 2 ch. pan.
{ Pan2.ar(PinkNoise.ar(0.2), SinOsc.kr(0.5)) }.play;


//

(
// the arg direct will control the proportion of direct to processed signal
SynthDef("tutorial-DecayPink", { arg outBus = 0, effectBus, direct = 0.5;
  var source;
  // Decaying pulses of PinkNoise. We'll add reverb later.
  source = Decay2.ar(Impulse.ar(1, 0.25), 0.01, 0.2, PinkNoise.ar);
  // this will be our main output
  Out.ar(outBus, source * direct);
  // this will be our effects output
  Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-DecaySin", { arg outBus = 0, effectBus, direct = 0.5;
  var source;
  // Decaying pulses of a modulating sine wave. We'll add reverb later.
  source = Decay2.ar(Impulse.ar(0.3, 0.25), 0.3, 1, SinOsc.ar(SinOsc.kr(0.2, 0, 110, 440)));
  // this will be our main output
  Out.ar(outBus, source * direct);
  // this will be our effects output
  Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-Reverb", { arg outBus = 0, inBus;
  var input;
  input = In.ar(inBus, 1);

  // a low-rent reverb
  // aNumber.do will evaluate its function argument a corresponding number of times
  // {}.dup(n) will evaluate the function n times, and return an Array of the results
  // The default for n is 2, so this makes a stereo reverb
  16.do({ input = AllpassC.ar(input, 0.04, { Rand(0.001,0.04) }.dup, 3)});

  Out.ar(outBus, input);
}).add;

b = Bus.audio(s,1); // this will be our effects bus
)

(
x = Synth.new("tutorial-Reverb", [\inBus, b]);
y = Synth.before(x, "tutorial-DecayPink", [\effectBus, b]);
z = Synth.before(x, "tutorial-DecaySin", [\effectBus, b, \outBus, 1]);
)

// Change the balance of wet to dry
y.set(\direct, 1); // only direct PinkNoise
z.set(\direct, 1); // only direct Sine wave
y.set(\direct, 0); // only reverberated PinkNoise
z.set(\direct, 0); // only reverberated Sine wave
x.free; y.free; z.free; b.free;

//
y.free;
z.free;
y.set(\direct, 0.85); // only reverberated Sine wave
z.set(\direct, 0.85); // only reverberated Sine wave
