/*
	*
	* a supercollider sound & music server for scroll-link-server
	*
	* dhy @ dianaband @ 2018. 07. 28.
	*
*/

//NOTE: assuming that 8ch I/O is available.
//      --> http://doc.sccode.org/Reference/StartupFile.html
//
//      so, my configuration file '~/.config/SuperCollider/startup.scd' contains:
//
//      Server.local.options.numOutputBusChannels = 8;
//      Server.local.options.numInputBusChannels = 8;
//      Server.internal.options.numOutputBusChannels = 8;
//      Server.internal.options.numInputBusChannels = 8;
//
//      then, local/internal server will have by default 8 ch. I/O
//

// PanAz

// PanAz.ar(numChans, in, pos: 0, level: 1, width: 2, orientation: 0.5)
// PanAz.kr(numChans, in, pos: 0, level: 1, width: 2, orientation: 0.5)

// Arguments:
// numChans    	- Number of output channels.
// in           - The input signal.
// pos          - pan position (kr or ar).
//                Channels are evenly spaced over a cyclic period of 2.0 in pos
//                with 0.0 equal to channel zero
//                and 2.0/numChans equal to channel 1,
//                4.0/numChans equal to channel 2, etc.
//                Thus all channels will be cyclically panned through...
//                if a bipolar sawtooth wave from -1 to +1 is used to modulate the pos.
// level        - A control rate level input.
// width        - The width of the panning envelope.
//                Nominally this is 2.0 which pans between pairs of adjacent speakers.
//                Values greater than 2 will spread the pan over greater numbers of speakers.
//                Values less than 1 will leave silent gaps between speakers.
// orientation  - Should be 0 if the front is a vertex of the spanning polygon.
//                The first speaker will be directly in front.
//                Should be 0.5 if the front bisects a side of the spanning polygon.
//                Then the first speaker will be the one left of center.

s.boot;
s.queryAllNodes(true);
s.plotTree;
s.meter;

//sessions
~nch = 6;
currentEnvironment.postln

//PanAz simple
Ndef(\ss).play(0, ~nch); //.play(out, numChannels, group, multi: false, vol, fadeTime, addAction) // NodeProxy
Ndef(\ss).fadeTime = 2;
(
//
Ndef(\ss, {
	arg freq=440, pan=0, amp=0.1;
	var out, sig;
	out = SinOsc.ar(freq:freq, mul:amp);
	sig = PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
	//Out.ar(0, sig);
});
//
)
Ndef(\ss).stop;
//why this doesn't work?
//    --> if u use Out.ar independently..
//        then.. somehow this doesn't work. anymore.
//        probably because play/stop is managing Out bus.. to play/stop..
//        but it will have it's own connection to the bus. so doens't get controlled.
//        and also xset doesn't work..
//        all is specially supported func. of NodeProxy system.
Ndef(\ss).clear;
s.meter;
//
Ndef(\ss).xset(\pan, 0/~nch);
Ndef(\ss).xset(\pan, 2/~nch);
Ndef(\ss).xset(\pan, 4/~nch);
Ndef(\ss).xset(\pan, 6/~nch);
Ndef(\ss).xset(\pan, 8/~nch);
Ndef(\ss).xset(\pan, 10/~nch);
//
Ndef(\ss_pan).mold(1, \control);
Ndef(\ss_pan, {	LFSaw.kr(\freq.kr(1)) + 1 }); // 1Hz A non-band-limited sawtooth oscillator
Ndef(\ss_pan).clear;
//
Ndef(\ss) <<>.pan Ndef(\ss_pan);
//
Ndef(\ss).xset(\amp, 0.2);
Ndef(\ss).xset(\freq, 440);
Ndef(\ss_pan).xset(\freq, 0.2);
//
s.queryAllNodes
Ndef(\ss).stop;
Ndef(\ss)[0] // Ndef(key)[0] : this is a Function of Ndef.... but it is no-where documented.. fuck.
//
(
//
Ndef(\tt, {
	arg freq=440, pan=0, amp=0.1;
	var out;
	out = Klank.ar(`[{[300, 1071, 1153, 1723]}, nil, [1, 1, 1, 1]], Impulse.ar(freq, 0, 0.1)) * amp;
	//PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
	PanAz.ar(~nch, out, pan, 1, 2, 0.5);
});
//
)
//
Ndef(\tt).fadeTime = 2;
Ndef(\tt).play(0, 6);
Ndef(\tt) <<>.pan Ndef(\ss_pan);
Ndef(\ss_pan).xset(\freq, 1);
Ndef(\tt).xset(\amp, 4);
Ndef(\tt).xset(\amp, 1);
Ndef(\tt).xset(\freq, 6);
Ndef(\tt).stop;
//
Array
Pdef(\rr, Pseq([], inf));
Ndef(\rr).clear;
Ndef(\rr).mold(1, \control);
Pdef(\rr, {
	Pseq(`[300, 1071, 1153, 1723], inf);
});
Ndef(\rr)[0] = Pdef(\rr);

//`(backtick or backquote) define a Ref : `1 == Ref(1), `(a+1) == Ref(a+1)
//Refs are most commonly used to prevent multi-channel expansion in SynthDefs and Patterns (see Klank for an example).

//session # 1
//circles. chamber music. ensemble.
Ndef(\aa).play;
Ndef(\aa).fadeTime = 1;
Ndef(\cc).play;
c = Bus.control(s);
c = 440;
c = 330;
Ndef
PanAz
Ndef(\aa, {SinOsc.ar(\freq.kr([150, 330]))});
Ndef(\aa).xset(\freq, [150, 230]);
Ndef(\aa).xset(\freq, [c, c + 50]);
Ndef(\cc, {SinOsc.kr(1) * 440}) <>> c;
Ndef(\aa).stop;
Ndef(\cc).stop;
Pdefn(\tut0_grav, Pseq([0.5], inf));
Pdefn(\tut0_damp, Pseq([0.05], inf));
(
Pdef(\tut0,
	Pbind(
		\instrument, \tball,
		\grav, Pdefn(\tut0_grav),
		\damp, Pdefn(\tut0_damp),
	)
).play
)

Ndef(\sound, { SinOsc.ar([600, 635], Ndef.ar(\sound), LFNoise1.kr(2).max(0) * 0.2) });
Ndef(\sound).play;
Ndef.clear;
Ndef(\sound).edit;
Ndef(\sound).edit
(
Ndef(\sound, { |freq = 440, rate = 2|
    SinOsc.ar(freq * [1, 1.625]) * SinOsc.kr(rate).max(0) * 0.2
}).play;
)

(
Pdefn(\tut1_notes, Pseq([80], inf));
Pdefn(\tut1_dectime, Pseq([0.01], inf));
Pdef(\tut1,
	Pbind(
		\instrument, \ring,
		\midinote, Pdefn(\tut1_notes),
		\dectime, Pdefn(\tut1_dectime),
		\db, 10
	)
).play
)

(
{
    PanAz.ar(
        numChans: 6,
        in: ClipNoise.ar(0.1),
        pos: LFSaw.kr(MouseX.kr(0.1, 2, 'exponential')),
        level: 0.5,
        width: 1,
        orientation: 0.5
    );
}.scope
)
(
//
Ndef(\bb, {
	arg freq=440, pan=0, amp=0.1;
	var out;
	out = ClipNoise.ar(0.1) * amp;
	//PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
	PanAz.ar(~nch, out, pan, 1, 2, 0.5);
}).play;
//
)
Ndef(\bb).play;
Ndef(\bb).fadeTime = 2;
Ndef(\bb) <<>.pan Ndef(\ss_pan);
Ndef(\ss_pan).set(\freq, 0.1);
Ndef(\bb).xset(\amp, 4);
Ndef(\bb).xset(\amp, 1);
Ndef(\bb).xset(\pan, 1/6);
Ndef(\bb).xset(\pan, 3/6);
Ndef(\bb).xset(\pan, 5/6);
Ndef(\bb).xset(\pan, 7/6);
Ndef(\bb).xset(\pan, 9/6);
Ndef(\bb).xset(\pan, 11/6);

Ndef(\a, { SinOsc.ar([350, 351.3], 0, 0.2) });
Ndef(\a, { SinOsc.ar([330, 351.3], 0, 0.2) });
Ndef(\a).play
Ndef(\a).fadeTime = 2;
Ndef(\a).stop
Ndef.dictFor(s);
Ndef.all;

(
//
Pdefn(\tut_notes, Pseq([60,63,65], inf));
Pdefn(\tut_dur, Pseq([0.1], inf));
//
Pdef(\tut,
	Pbind(
		\instrument, \sine_percussive,
		\dur, Pdefn(\tut_dur),
		\midinote, Pdefn(\tut_notes),
		\amp, 0.1,
		\out, 0
	)
)
//
)
Pdef(\tut).quant = 0; // no waiting. //for the start beat // how this one changes.. the result? don't get it yet..
Pdefn(\tut_dur).quant = 1; // no waiting. //for the start beat
//
Pdefn(\tut_dur, Pseq([0.03], inf));
Pdef(\tut).play;
Pdef(\tut).stop;
//
Pdefn(\tut_notes, Pseq([68,73,85], inf));
Pdefn(\tut_notes, (Pexprand(80, 100, inf) - 1).round);
Pdefn(\tut_notes, Pwrand(#[65, 58, 61], #[0.5, 0.3, 0.2], inf));
//
Pdefn(\tut_dur, Pexprand(0.1, 0.8, inf));
Pdefn(\tut_dur, Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf));

Pdefn(\tut_notes, Pbrown(80, 76, 0.1, inf));
Pdef(\x).quant = 0; // no waiting.
Pbindf(Pdef(\x), \dur, 0.03).play;
Pbindf(Pdef(\x), \dur, 0.1, \ctranspose, 15).play;
Pbindf(Pdef(\x), \dur, 0.3, \ctranspose, 2).play;

p.stop;

Pdef(\tut2, Pbind(\instrument, \sine_percussive, \dur, 0.1, \midinote, Pseq([60, 62, 67], inf), \amp, 0.1));

//session # 1
//
Synth.tail(1, \piano_soundboard);
//
(
Pbind(
    \instrument, \piano,
    \delta, 1,
    \dur, 3,
    \degree, Pseq([1,3,5], inf),
    \out, 20,
).play;
)

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


//piano player
Pdef(\piano_player,
	Pbind(
		\instrument, \piano,
		\delta, 1,
		\dur, 3,
		\degree, Pseq([1,3,5], inf),
		\out, 20,
    );
)
Pdef(\piano_player).play;
Pdef(\piano_player).stop;

//bow player
Pdef(\bow_player,
	Pbind(
		\instrument, \bowing,
		\delta, 1,
		\dur, 3,
		\degree, Pseq([1,3,5], inf),
		\out, 20,
    );
)
Pdef(\bow_player).play;
Pdef(\bow_player).stop;










//Understanding Pbind
//"the structure of the extensive default mechanism provided by Event."
//    --> file:///home/doohoyi/.local/share/SuperCollider/Help/Classes/Pbind.html#SynthDef%20and%20Event

//Pdef (Pbind) - event pattern
s.boot;

Pdef(\x, Pbind(\note, Pbrown(0, 6, 0.1, inf)));
Pdef(\x).quant = 0; // no waiting.
Pbindf(Pdef(\x), \dur, 0.03).play;
Pbindf(Pdef(\x), \dur, 0.1, \ctranspose, 15).play;
Pbindf(Pdef(\x), \dur, 0.3, \ctranspose, 2).play;
// now change the definition
Pdef(\x, Pbind(\note, Pseq([0, 3, 5, 7, 9, 11], inf)));
Pdef(\x, Pbind(\freq, Pseq([1000, 1923, 245.2, 1718] / 1.2 + 0.1, inf)));

//PatternProxy/Pdefn/Pn - value pattern
(
Pdefn(\degree, Pn(Pseries(0, 1, 8), inf)); // Pn is for repeating.
Pdefn(\dur, Pn(0.25, inf));

p = Pbind(
    \degree, Pdefn(\degree),
    \dur, Pdefn(\dur)
).play;
)

Pdefn(\degree, (Pexprand(1, 8, inf) - 1).round);

Pdefn(\dur, Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf));

p.stop;
