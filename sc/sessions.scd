/*
	*
	* a supercollider sound & music server for scroll-link-server
	*
	* dhy @ dianaband @ 2018. 07. 28.
	*
*/

s.boot;
s.queryAllNodes(true);

//server status
(
s.plotTree;
s.meter;
NdefMixer(s)
)

//environment
//~nch = 6; //mtrack8
~nch = 2; //headphone
currentEnvironment.postln

//TIP: clear Ndef
//Ndef(\node).clear;

//TIP: clear Synth by ID, when it has no 'name'
//s.sendMsg(\n_free, 1000);

//---------------------------------------------------------------------------------


SynthDescLib.global.browse;

NdefMixer(s)

s.boot;
Ndef.clear; // clear all Ndef
Ndef.defaultReshaping = \elastic;
Ndef(\x).play(0, 2);
Ndef(\x).fadeTime = 1.3;
Ndef(\y, { Dust.ar(115, 0.1) });
Ndef(\x, { Resonz.ar(Ndef.ar(\y), [700, 720], 0.001, 300) });
// \elastic reshaping differs at following code.
// without \elastic. --> Ndef('y'): wrapped channels from 2 to 1 channels
// i.e. \y was 1 ch. yet \x is 2 ch. so ME happened.
// then suddenly \y became 2 ch. then,
// without \elastic..
// \y -> \x bus should remain 1ch. so \y 'wrapping' to be 1ch.
// (don't know clearly what it is exactly, 'wrapping')
// and then ME to be 2ch.
// so it might be mix-down and duplicate or 2nd channel will be simply lost.
// with \elastic, redefine Bus to be 2ch. in between. then let ME happen as if \y was 2 ch. from start.
Ndef(\y, { Dust2.ar([3, 115], [1, 0.1]) });
Ndef(\x, { Resonz.ar(Ndef.ar(\y), [600, 1720], 0.01, 100) });
Ndef(\x, { Splay.ar(Resonz.ar(Ndef(\y), [600, 1720, 820, 1000] * 1.5, 0.01, 100)) });
Ndef(\y, { Dust.ar([3, 115, 5, 101] * 0.1, [1, 0.1]) });
Ndef(\y, { Dust.ar([3, 115, 5, 101] * 10, [1, 0.1]/2) });
Ndef(\y, { Dust.ar([1013, 415, 1115, 101] * (Ndef.kr(\aa) + 1), [0.1, 0.1]/2) });
Ndef(\aa, { Blip.ar([0.03, 0.05, 0.1], 3).exprange(0.1, 100) });
//\elastic also allows .ar <-> .kr
Ndef(\y, { Dust.ar([1013, 415, 1115, 101] * (Ndef.ar(\aa) + 1), [0.1, 0.1]/2) });
Ndef(\x, { Splay.ar(Resonz.ar(Ndef(\y), [600, 720, 320, 780] * (Ndef.ar(\aa).lag(0.01) * 0.3 + 1), 0.01, 100)).distort });
Ndef(\aa, { Blip.ar([1, 0.5, 0.4], 30).exprange(0.1, 10) });
Ndef(\y, { Impulse.ar([1, 2/3, 4/6, 2] * 100 * DelayC.ar(Ndef(\aa) + 1, 0.5, 0.5, 1, Ndef(\aa)), [0.1, 0.1]/2) });
Ndef(\y, { Impulse.ar([1, 2/3, 4/6, 2] * 4 * DelayC.ar(Ndef(\aa) + 1, 0.5, 0.5, 1, Ndef(\aa)), [0.1, 0.1]/2) });
Ndef(\y, { Impulse.ar([1, 2/3, 4/6, 2, 3] * 100 * DelayC.ar(Ndef.ar(\aa) + 1, 0.5, LFNoise1.kr(0.1 ! 4).range(0, 0.5), 1, Ndef.ar(\aa)), [0.1, 0.1]/2) });
Ndef(\y, { Impulse.ar([1, 2/3, 4/6, 2, 9/8] * 100 * DelayC.ar(Ndef.ar(\aa) + 1, 0.5, LFNoise1.kr(3 ! 2).range(0, 0.5), 1, Ndef(\aa)), [0.1, 0.1]/2) });
Ndef(\x, { Splay.ar(Resonz.ar(SplayAz.ar(4, Ndef.ar(\y)), [600, 720, 320, 780] * (Ndef.ar(\aa).lag(0.01) * 0.3 + 1), 0.01, 100)).distort });



// mold tests
s.boot; // important
Ndef.clear;
Ndef(\x).reshaping = \elastic;
Ndef(\x, { SinOsc.ar([277, 377, 663]) });
Ndef(\x).numChannels == 3;
Ndef(\x).mold(1, \audio);
// reshaping closely relates to 'molding' !
Ndef(\x).numChannels == 1;
Ndef(\x).rebuild; // ME expansion recovers..
Ndef(\x).numChannels == 3;
Ndef(\x).mold(2, \control);
Ndef(\x, { SinOsc.kr([277, 377, 663]) });
Ndef(\x).numChannels == 3;
Ndef(\x).rate == \control;

Ndef.clear;
Ndef(\x).reshaping = nil;
Ndef(\x, { SinOsc.ar([277, 377, 663]) });
Ndef(\x, { SinOsc.ar([277, 377, 663, 1000]) });
Ndef(\x).numChannels == 3;
Ndef(\x).mold;
Ndef(\x).numChannels == 4;
Ndef(\x).mold(1, \audio);
Ndef(\x).numChannels == 1;

s.quit;
Ndef.clear;
Ndef(\x).reshaping = nil;
Ndef(\x, { SinOsc.ar([277, 377, 663]) });
Ndef(\x, { SinOsc.ar([277, 377, 663, 1000]) });
Ndef(\x).numChannels == 3;
Ndef(\x).mold;
Ndef(\x).numChannels == 4;
Ndef(\x).mold(1, \audio);
Ndef(\x).numChannels == 1;
Ndef(\x).rebuild;
Ndef(\x).numChannels == 1;
Ndef(\x).mold(2, \control);
Ndef(\x, { SinOsc.kr([277, 377, 663]) });
Ndef(\x).numChannels == 2;

//isNeutral -> true if the proxy has no initialproxy has no ''
// testing channel init
Ndef.clear;
Ndef(\x).bus;
Ndef(\x).isNeutral;
Ndef(\x).ar(3);
Ndef(\x).ar(4);
Ndef(\x).numChannels == 3;
Ndef(\x, [1, 2, 3, 4, 5]);
Ndef(\x).numChannels == 3;
Ndef.clear;



NodeMap


//session # 1

//set # 1 - a ball
//boot-up a node
(
Ndef(\ball).play(0, ~nch); //.play(out, numChannels, group, multi: false, vol, fadeTime, addAction) // NodeProxy
Ndef(\ball).fadeTime = 2;
)
//the synth + preset
(
Ndef(\ball, {
	arg	pan=0;
	var out;
	out = Limiter.ar(
		out = Ringz.ar(
			TBall.ar(Pulse.ar(\ballfreq.kr(0.1), 0.5), \grav.kr(1), \damp.kr(0.01)) * \preamp.kr(100),
			\freq.kr(1220),
			\dectime.kr(0.01),
			mul:\amp.kr(1)
		),
		\limit.kr(2)
	);
	PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
	//Out.ar(0, out);
});
//preset
//physical dynamics
Ndef(\ball).set(\ballfreq, 0.1); //ground fluctuation freq.
Ndef(\ball).set(\grav, 0.15);    //gravity
Ndef(\ball).set(\damp, 0.01);    //friction-like
//preamp (before resonator)
Ndef(\ball).set(\preamp, 30);
//ringz
//Ndef(\ball).set(\freq, 1200);
Ndef(\ball) <<>.freq Ndef(\ballff, {(BrownNoise.kr() + 1) * \range.kr(50) + \freq.kr(800)});
Ndef(\ballff).set(\freq, 700);
Ndef(\ball).set(\dectime, 0.07);
Ndef(\ball).set(\amp, 1);
//limiter
Ndef(\ball).set(\limit, 2);
//output channel
Ndef(\ball).set(\pan, 1/~nch);
)
//extra.
//a gui controller
NdefGui(Ndef(\ball), 8);
//stop/clear
Ndef(\ball).stop;
Ndef(\ball).clear;



currentEnvironment.postln;



//set # 2 - a piano
//synthdef + soundboard node boot up + a private bus in-between
(
~otey_bus = Bus.audio(s, 1);
SynthDef(\piano, {
	var out, env;
	env = EnvGen.ar(Env.asr(0,1,0.1), \gate.kr(1), doneAction:Done.freeSelf);
	out = OteyPianoStrings.ar(\freq.kr(440), \amp.kr(0.5), rho:\rho.kr(1)) * env;
	Out.ar(~otey_bus, out);
}).add;
Ndef(\piano_sb, {
	var out;
	out = OteySoundBoard.ar(In.ar(~otey_bus, 1));
	PanAz.ar(~nch, out, (\pan.kr(0) + 0.5).mod(2), 0.5, 2, 0.5);
}).play(0, ~nch);
Ndef(\piano_sb).set(\pan, 7/~nch);
)
//clear soundboard
Ndef(\piano_sb).clear;
//output channel
Ndef(\piano_sb).set(\pan, 11/~nch);
//a player
(
Pdef(\pplay,
	Pbind(
		\instrument, \piano,
		\degree, Prand((0..12), inf),
		\dur, Prand((1..5), inf),
		\amp, 0.5,
		\mtranspose, Prand((0..3), inf)
	)
).play; // returns an EventStream
)
//player stop
Pdef(\pplay).stop;
//panning
Ndef(\piano_sb).set(\pan, 7/~nch);



//panning example
//lfo
Ndef(\lfo).mold(1, \control);
Ndef(\lfo, {(LFSaw.kr(\freq.kr(1)) + 1) / 2 * \mul.kr(1) + \add.kr(0)});
Ndef(\lfo).set(\freq, 0.2);
Ndef(\lfo).set(\mul, 2);
Ndef(\lfo).set(\add, 0);
//let them pannnnn...
Ndef(\piano_sb) <<>.pan Ndef(\lfo);
Ndef(\ball) <<>.pan Ndef(\lfo);
Ndef(\buf_i) <<>.pan Ndef(\lfo);




// //set # 3 - klank
// //boot up a nodeproxy
// (
// Ndef(\tt).play(0, ~nch);
// Ndef(\tt).fadeTime = 2;
// )
// //synth
// (
// SynthDef(\klank, {
// 	arg pan=0;
// 	var out;
// 	Done
// 	out = Klank.ar(`[[300, 1071, 1153, 1723], nil, [1, 1, 1, 1]], .tr) * \amp.kr(0.1);
// 	//PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
// 	PanAz.ar(~nch, out, pan, 1, 2, 0.5);
// }).add;
// )
// (
// Ndef(\tt, {
// 	arg pan=0;
// 	var out;
// 	out = Klank.ar(`[[300, 1071, 1153, 1723], nil, [1, 1, 1, 1]], Impulse.ar(\freq.kr(1), 0, 0.1)) * \amp.kr(0.1);
// 	//PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
// 	PanAz.ar(~nch, out, pan, 1, 2, 0.5);
// });
// )
// (
// Pdef(\kl_player,
// 	Pbind(
// 		\instrument, \klank,
// 		\dur, 0.2
// 	)
// ).stop;
// )





//set # 4 - low (MoogFF)
//boot up a nodeproxy
(
Ndef(\low, {
	var in, out, freq, gain;
	in = LFSaw.ar(\base.kr(50));
	freq = LFTri.kr(\freq.kr(0.1)) * 200 + 500;
	gain = LFTri.kr(\gain.kr(3)) * 0.65 + 3.15;
	out = MoogFF.ar(in, freq, gain) * \amp.kr(1);
	PanAz.ar(~nch, out, (\pan.kr(0) + 1).mod(2), 0.5, 2, 0.5);
}).play(0, ~nch);
Ndef(\low).fadeTime = 2;
Ndef(\low).xset(\amp, 0.0);
Ndef(\low).xset(\amp, 1.5);
Ndef(\low).xset(\base, 120);
Ndef(\low).xset(\freq, 0.8);
Ndef(\low).xset(\gain, 0.5);
Ndef(\low).xset(\base, 1000);
Ndef(\low) <<>.pan Ndef(\lfo);
)
//preset
(
Ndef(\low).xset(\base, 20);
Ndef(\low).xset(\amp, 2);
Ndef(\low).xset(\amp, 0);
Ndef(\low).stop;








//set # 5 - am 1
(
SynthDef("am1", {
    var carrier, modulator, env;
    env = Env.perc(
        attackTime: \att.kr(0.01),
        releaseTime: \rel.kr(3),
        level: \amp.kr(0.2)
    ).kr(2);
    modulator = SinOsc.ar(\modfreq.kr(2)).range(0, 1);
    carrier = SinOsc.ar(freq: \freq.kr(10), mul: env * modulator);
    Out.ar(0, carrier ! 2);
}).add;
)

(
Pdef(\snd3,
	Pbind(
		\instrument, "am1",
		//\degree, Prand([0, 2], inf),
		\degree, Prand([0, 2, 5, 3.5, -5], inf), //a bit jazzy!
		\modfreq, Prand([1, 5, 10, 50, 100], inf),
		\amp, 0.4,
		\dur, 0.2,
		\att, 0.01,
		\rel, Pwhite(0.3, 0.5),
		\pos, Pwhite(-1, 1.0)
	)
).play;
)

//a nice playing seq - a bit jazzy!
(
Pdef(\snd3,
	Pbind(
		\instrument, "am1",
		//\degree, Prand([0, 2], inf),
		\degree, Prand([0, 2, 5, 3.5, -5], inf), //a bit jazzy!
		\modfreq, Prand([1, 5, 10, 50, 100], inf),
		\amp, 0.4,
		\dur, 0.2,
		\att, 0.01,
		\rel, Pwhite(0.3, 0.5),
		\pos, Pwhite(-1, 1.0)
	)
).stop;
)










//set # 5 - buf (interference)
~buf_i = Buffer.read(s, Platform.userHomeDir +/+ "Paperjs.sync/scroll-link-server/sc/audio/interference1.wav");
~buf_i.free;
currentEnvironment.postln;
(
Ndef(\buf_i, {
	var out;
	//out = PlayBuf.ar(2, ~buf_i, BufRateScale.kr(~buf_i), doneAction:Done.freeSelf);
	out = Mix.ar(PlayBuf.ar(2, ~buf_i, (BufRateScale.kr(~buf_i)), loop:1)) * \amp.kr(1);
	PanAz.ar(~nch, out, (\pan.kr(0) + 1).mod(2), 0.5, 2, 0.5);
}).play(0, ~nch);
Ndef(\buf_i).fadeTime = 2;
Ndef(\buf_i).xset(\amp, 10);
Ndef(\buf_i).xset(\rate, BufRateScale.kr(~buf_i));
~abc = NodeProxy.new;
~abc.source = BufRateScale.kr(~buf_i);
currentEnvironment.postln;
Ndef(\buf_i) <<>.rate ~abc;
Ndef(\buf_i).xset(\pan, 8/~nch);
Ndef(\buf_i) <<>.pan Ndef(\lfo);
)
//preset
(
Ndef(\low).xset(\base, 20);
Ndef(\low).xset(\amp, 2);
Ndef(\low).xset(\amp, 0);
Ndef(\low).stop;
(
x = SynthDef(\bufplay,{ arg out = 0, bufnum;
    Out.ar(out, PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)));
}).play(s,[\bufnum, b]);
)
x.free;
~interf.free;











// 1. define the synth
(
SynthDef(\bell, {
	|fs=1, t60=1, pitchy=1, amp=0.25, gate=1|
	var sig, exciter;
	//exciter = Impulse.ar(0);
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = Klank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:fs*pitchy);
	sig = FreeVerb.ar(sig) * amp;
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, sig!2);
}).add
)


// 2. Test a single note
x = Synth(\bell, [\fs, 60.midicps, \t60, 9.177, \pitchy, 8]);


// 3. Test different textures

// glokenspiel
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 6,
	\pitchy, 4,
	\dur, 0.25
).play;
)

// tubular bells
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 9,
	\pitchy, 1,
	\dur, 1
).play;
)

// xilophone
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 1,
	\pitchy, 4,
	\dur, 0.25
).play;
)

// marimba
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 0.5,
	\pitchy, 1,
	\dur, 0.25
).play;
)








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
