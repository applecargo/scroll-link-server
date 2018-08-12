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
s.makeGui;

(

~nchannels = 2;

//sine osc.
SynthDef(\sine, {
	arg out=0, freq=300, amp=1;
	var sig;
	sig = SinOsc.ar(freq:freq, mul:amp);
	ReplaceOut.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//sine percussive
SynthDef(\bufplay, {
	arg out=0, freq=300, amp=1;
	var sig, env;
	env = EnvGen.kr(Env.perc, doneAction: Done.freeSelf);
	sig = SinOsc.ar(freq:freq, mul:amp) * env;
	Out.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//gain
SynthDef(\gain, {
    arg ibs=0, out=0, amp=1;
	var in, sig;
	in = In.ar(ibs, ~nchannels);
	sig = in * amp;
	ReplaceOut.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//tball
SynthDef(\tball, {
	arg ibs=0, out=0, grav=1, damp=0.01;
	var sig;
	sig = TBall.ar(Pulse.ar(0.1, 0.5), grav, damp);
	Out.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//ring
SynthDef(\ring, {
	arg ibs=0, out=0, amp=1, freq=1200, dectime=0.01;
	var in, sig;
	in = In.ar(ibs, ~nchannels);
	sig = Ringz.ar(in, freq, dectime, mul:amp);
	ReplaceOut.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//reson
SynthDef(\reson, {
	arg ibs=0, out=0, amp=1, freq=1200, bwr=0.1;
	var in, sig;
	in = In.ar(ibs, ~nchannels);
	sig = Resonz.ar(in, freq, bwr, mul:amp);
	ReplaceOut.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//reverb
SynthDef(\verb, {
	arg ibs=0, out=0, amp=1, mix=0.5, room=0.5, damp=0.7;
	var in, sig;
	in = In.ar(ibs, ~nchannels);
	sig = FreeVerb.ar(in, mix, room, damp, mul:amp);
	ReplaceOut.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//piano
SynthDef(\piano, {
	arg ibs=0, out=0, freq=440, gate=1, amp=0.5, rho=1;
	var sig;
	sig = OteyPianoStrings.ar(freq, amp, rho:rho) * EnvGen.ar(Env.asr(0,1,0.1), gate, doneAction:2);
	Out.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

//piano_soundboard
SynthDef(\piano_soundboard, {
	arg out=0;
    var audio = In.ar([20, 21], );
    audio = OteySoundBoard.ar(audio);
    Out.ar(out, audio);
}).add;

//bowing
SynthDef(\bowing, {
	arg out=0, freq=220, gate=1, amp=1, bowpressure=64, bowposition=17, vibfreq=50, vibgain=1, loudness=128;
    var sig, env;
    env = EnvGen.kr(Env.asr(0,1,0.1),gate,doneAction:2);
    sig = StkInst.ar(Stk.at("Bowed"), freq, gate, amp, 0.5, [2, bowpressure, 4, bowposition, 11, vibfreq, 1, vibgain, 128, loudness]) * env;
    Out.ar(out, NumChannels.ar(sig, ~nchannels));
}).add;

// SynthDef("tutorial-DecayPink", { arg outBus = 0, effectBus, direct = 0.5;
// 	var source;
// 	source = Decay2.ar(Impulse.ar(1, 0.25), 0.01, 0.2, PinkNoise.ar);
// 	Out.ar(outBus, source * direct);
// 	Out.ar(effectBus, source * (1 - direct));
// }).add;

// SynthDef("tutorial-DecaySin", { arg outBus = 0, effectBus, direct = 0.5;
// 	var source;
// 	source = Decay2.ar(Impulse.ar(0.3, 0.25), 0.3, 1, SinOsc.ar(SinOsc.kr(0.2, 0, 110, 440)));
// 	Out.ar(outBus, source * direct);
// 	Out.ar(effectBus, source * (1 - direct));
// }).add;

// SynthDef("tutorial-Reverb", { arg outBus = 0, inBus;
// 	var input;
// 	input = In.ar(inBus, 1);
// 	16.do({ input = AllpassC.ar(input, 0.04, { Rand(0.001,0.04) }.dup, 3)});
// 	Out.ar(outBus, input);
// }).add;

)
