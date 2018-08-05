s.boot;

Pdefn(\x, Pbrown(0, 6, 0.1, inf));
Pbind(\note, Pdefn(\x), \dur, 0.3).play;
Pbind(\note, Pdefn(\x), \dur, 0.1, \ctranspose, 15).play;
// now change the definition
Pdefn(\x, Pseq([0, 3, 5, 7, 9, 11], inf));
Pdefn(\x, Pseq([0, 3, 3, 7], inf) + Pseq([0, [0, 3], [0, 5, 7]], inf));







SynthDef(\synth1, {arg out=0, freq=440, envdur=1, amp=0.4, pan=0;
    var x, env;
    env = EnvGen.kr(Env.perc(0.001, envdur, amp), doneAction:2);
    x = Mix.ar([FSinOsc.ar(freq, pi/2, 0.5), Pulse.ar(freq,Rand(0.3,0.7))]);
    x = RLPF.ar(x,freq*4,Rand(0.04,1));
    x = Pan2.ar(x,pan);
    Out.ar(out, x*env);
}).add;

Pdefn(\scaleholder, { |arr| Pseq(arr.freqarr) });
// and we add an array to it
Pdefn(\scaleholder).set(\freqarr, Array.fill(6, {440 +(300.rand)} ));

Pdef(\scale,
		Pbind( 	\instrument, \synth1,
				\freq, Pn(Pdefn(\scaleholder), inf), // loop
				\dur, 0.4
			)

);
a = Pdef(\scale).play;

// and we can reset our scale
Pdefn(\scaleholder).set(\freqarr, Array.fill(3, {440 +(300.rand)} ));
a.stop;











(
Pdefn(\deg, Pseq([0, 3, 2],inf));

Pset(\instrument, \synth1,
	Ppar([
		Pbind(\degree, Pdefn(\deg)),
		Pbind(\degree, Pdefn(\deg), \dur, 1/3)
])
).play;
)

Pdefn(\deg, Prand([0, 3, [1s, 4]],inf));
Pdefn(\deg, Pn(Pshuf([4, 3, 2, 7],2),inf));
Pdefn(\deg, Pn(Pshuf([0, 3],2),inf));

(
Pdefn(\deg, Plazy { var pat;
				pat = [Pshuf([0, 3, 2, 7, 6],2), Pshuf([3, 2, 6],2), Pseries(11, -1, 11)].choose;
				Pn(pat, inf)
		});
)












(
~scale = [62,67,69, 77];

c = Pdef(\p04b,
		Pbind(\instrument, \synth1,
					\freq, (Pseq.new(~scale, inf)).midicps, // freq arg
					\dur, Pseq.new([1, 1, 1, 1], inf);  // dur arg
		)
);

c = Pdef(\p04c,
		Pbind(\instrument, \synth1,
					\freq, (Pseq.new(~scale, inf)).midicps, // freq arg
					\dur, Pseq.new([1, 1, 1, 1], inf);  // dur arg
		)
);
)

Pdef(\p04b).quant_([2, 0, 0]);
Pdef(\p04c).quant_([2, 0.2, 0]); // offset by half a beat
Pdef(\p04b).play;
Pdef(\p04c).play;
//(quant can't be reset in real-time, so we use align to align patterns). align takes the same arguments as quant (see helpfile of Pdef)
Pdef(\p04c).align([4, 0, 0]);
Pdef(\p04c).align([4, 0.75, 0]); // offset by 3/4 a beat












~notes = List[63, 61, 64, 65];

Pbind(
	\midinote, Pseq(~notes, inf),
	\dur, Pseq([0.4, 0.2, 0.1, 0.2], inf)
).play;

~notes[1] = 80










(
Pbind(
 	\midinote, Pseq([72, 76, 79, 71, 72, 74, 72, 81, 79, 84, 79, 77, 76, 77, 76], 1),
 	\dur, Pseq([4, 2, 2, 3, 0.5, 0.5, 4, 4, 2, 2, 2, 1, 0.5, 0.5, 2]/4, 1)
 ).play
)











//USING Pfx (effects patterns)
(
SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
    var env, in;
    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
    in = In.ar(out, 2);
    XOut.ar(out, env, CombL.ar(in * env, maxdtime, dtime, decay, 1, in));
}, [\ir, \ir, 0.1, 0.1, 0]).add;

SynthDef(\distort, { arg out=0, pregain=40, amp=0.2, gate=1;
    var env;
    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
    XOut.ar(out, env, (In.ar(out, 2) * pregain).distort * amp);
}, [\ir, 0.1, 0.1, 0]).add;

SynthDef(\wah, { arg out=0, gate=1;
    var env, in;
    env = Linen.kr(gate, 0.05, 1, 0.4, 2);
    in = In.ar(out, 2);
    XOut.ar(out, env, RLPF.ar(in, LinExp.kr(LFNoise1.kr(0.3), -1, 1, 200, 8000), 0.1).softclip * 0.8);
}, [\ir, 0]).add;
)

(
var p, q, r, o;
p = Pbind(\degree, Prand((0..7),12), \dur, 0.3, \legato, 0.2);

q = Pfx(p, \echo, \dtime, 0.2, \decay, 3);

r = Pfx(q, \distort, \pregain, 20, \amp, 0.25);

o = Pfx(r, \wah);

Pseq([p, q, r, o], 2).play;
)








//Mozart
(
var instr = \default;
Ppar([
// right hand - using the Event-style notation
Pseq([
        (\instrument: instr, \midinote: 72, \dur: 1),
        (\instrument: instr, \midinote: 76, \dur: 0.5),
        (\instrument: instr, \midinote: 79, \dur: 0.5),
        (\instrument: instr, \midinote: 71, \dur: 0.75),
        (\instrument: instr, \midinote: 72, \dur: 0.125),
        (\instrument: instr, \midinote: 74, \dur: 0.125),
        (\instrument: instr, \midinote: 72, \dur: 1),
        (\instrument: instr, \midinote: 81, \dur: 1),
        (\instrument: instr, \midinote: 79, \dur: 0.5),
        (\instrument: instr, \midinote: 84, \dur: 0.5),
        (\instrument: instr, \midinote: 79, \dur: 0.5),
        (\instrument: instr, \midinote: 77, \dur: 0.25),
        (\instrument: instr, \midinote: 76, \dur: 0.125),
        (\instrument: instr, \midinote: 77, \dur: 0.125),
        (\instrument: instr, \midinote: 76, \dur: 1)
], 1),

// left hand - array notation
Pbind(\instrument, instr,
        \midinote, Pseq([60, 67, 64, 67, 60, 67, 64, 67, 62, 67, 65, 67, 60, 67, 64, 67,
	                 60, 69, 65, 69, 60, 67, 64, 67, 59, 67, 62, 67, 60, 67, 64, 67 ], 1),
        \dur, 0.25
        )], 1).play
)











//last ex
SynthDef(\string, {arg out=0, freq=440, pan=0, sustain=0.5, amp=0.3;
	var pluck, period, string;
	pluck = PinkNoise.ar(Decay.kr(Impulse.kr(0.005), 0.05));
	period = freq.reciprocal;
	string = CombL.ar(pluck, period, period, sustain*6);
	string = LeakDC.ar(LPF.ar(Pan2.ar(string, pan), 12000)) * amp;
	DetectSilence.ar(string, doneAction:2);
	Out.ar(out, string)
}).add;


SynthDef(\impulse, {
	Out.ar(0, Impulse.ar(0)!2);
}).add

Synth(\impulse)

Pbind(
	\instrument, \impulse,
	\dur, 1
).play(TempoClock.default, quant:1)

// not working
TempoClock.default.play({
	Synth(\impulse, [\amp, 2]); // this is the problem
	1.0
	}, quant:[1, Server.default.latency] );

// working
TempoClock.default.play({
	s.sendBundle(0.2, ["/s_new", \impulse, s.nextNodeID, 0, 1]);
	1.0
	}, quant:[1, 0] );

TempoClock.default.tempo = 2.5

Pbind(
	\instrument, \string,
	\freq, Pseq([440, 880], inf),
	\dur, 1
).play(TempoClock.default, quant:1);

TempoClock.default.play({arg i;
	s.sendBundle(0.2, ["/s_new", \string, s.nextNodeID, 0, 1, \freq, if(i.asInteger.even, {660}, {770}), \amp, 0.3]);
	1.0
	}, quant:[1, 0] );
