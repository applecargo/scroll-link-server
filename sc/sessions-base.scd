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

//sessions
~nch = 6; //mtrack8
//~nch = 2; //headphone
currentEnvironment.postln
Ndef(\aa).clear; //clear Ndef
s.sendMsg(\n_free, 2550); //clear Synth by ID, when it has no 'name'

//session # 1

//player 'aa'
Ndef(\aa).play(0, ~nch); //.play(out, numChannels, group, multi: false, vol, fadeTime, addAction) // NodeProxy
Ndef(\aa).fadeTime = 2;
Ndef(\aa).xset(\pan, 1/~nch); // select only 1 speaker.
Ndef(\aa).xset(\pan, 3/~nch); // select only 1 speaker.
(
//
Ndef(\aa, {
	arg	pan=0;
	var out;
	//out = Limiter.ar(
	out = Ringz.ar(
			TBall.ar(Pulse.ar(\ballfreq.kr(0.1), 0.5), \grav.kr(1), \damp.kr(0.01)) * \preamp.kr(100),
			\freq.kr(1220),
			\dectime.kr(0.01),
			mul:\amp.kr(1)
	);
	PanAz.ar(~nch, out, pan, 0.5, 1, 0.5);
	//Out.ar(0, out);
}).play;
//
)
//
Ndef(\aa).stop;
Ndef(\aa).clear;
//case 1
NdefGui(Ndef(\aa), 8);
//
Ndef(\aa).xset(\ballfreq, 0.2);
Ndef(\aa).xset(\grav, 0.2);
Ndef(\aa).xset(\damp, 0.1);
//
Ndef(\aa).xset(\preamp, 300);
//
Ndef(\aa).xset(\freq, 250);
Ndef(\aa).xset(\dectime, 0.01);
Ndef(\aa).xset(\amp, 1.5);
//
Ndef(\aa) <<>.pan Ndef(\lfo);
//





Ndef(\bb).play(0, ~nch);
Ndef(\bb).fadeTime = 2;
//


//a private bus for oteysoundboard
~otey_bus = Bus.audio(s, ~nch);

//
// what is OteySoundBoard? and how to use it?
// --> https://github.com/supercollider/sc3-plugins/blob/master/source/OteyPianoUGens/OteyPiano.cpp#L227
//    it is a group of filters and a reverb.
//    so this has been made separate for performance.
//    simply want to reuse those effects for many piano strikes.
// --> Otey Piano is a full-set and Otey Piano Strings & Soundboard is parts of the full-set
//     Otey Piano == (Otey Piano Strings + Sound Board) which will have advantage on Many* strings playing at the same time.
// --> so basically..
//     Otey Piano String --(a private bus)--> Otey Sound Board --> Out bus
//
(
//
SynthDef(\piano_sb, {
	var out;
	out = OteySoundBoard.ar(
		//In.ar(\in.kr(100), ~nch) // 100 --> later properly assign private bus here.
		In.ar(\in.kr(100), 1) // 100 --> later properly assign private bus here.
	);
	out = PanAz.ar(~nch, out, \pan.kr(0), 0.5, 1, 0.5);
	Out.ar(\out.kr(0), out);
}).add;
//
SynthDef(\piano, {
	var out, env;
	env = EnvGen.ar(Env.asr(0,1,0.1), \gate.kr(1), doneAction:Done.freeSelf);
	out = OteyPianoStrings.ar(\freq.kr(440), \amp.kr(0.5), rho:\rho.kr(1)) * env;
	Out.ar(\out.kr(100), out); // 100 --> later properly assign private bus here.
}).add;
//
)
~sb = Synth.tail(1, \piano_sb, [\in, ~otey_bus, \out, 0]);
~sb.set(\pan, 1/~nch); // select only 1 speaker.
~sb.set(\pan, 3/~nch); // select only 1 speaker.
~nch
~sb.free;
//
~pno = Synth(\piano, [\gate, 1, \out, ~otey_bus]);
~pno.set(\gate, 0); // here we have to release this explicitly. (when using Pdef..\dur will handle this.)
//understanding 'gate' --> there's 2 kinds of behaviour according to which Env is being used here.
// --> http://doc.sccode.org/Classes/EnvGen.html
//
// gate
// This triggers the envelope and holds it open while > 0.
//
// (1) If the Env is fixed-length (e.g. Env.linen, Env.perc),
//     --> the gate argument is used as a simple trigger.
// (2) If it is an sustaining envelope (e.g. Env.adsr, Env.asr),
//     --> the envelope is held open until the gate becomes 0, at which point is released.
//
// (a forced end case) If gate < 0, force release with time -1.0 - gate. See Forced release below.
//
~pno.free;
//

//pno player
(
//
Pdef(\pplay,
	Pbind(
		\instrument, \piano,
		//\degree, Prand((0..12), inf),
		\degree, Prand([1,4,7,12,8,3,2,5], inf),
		//\dur, Prand([3, 2], inf),
		\dur, Prand([0.2,1,0.3,1,1,1], inf),
		\delta, 0.2,
		\amp, 0.5,
		\out, ~otey_bus,
		//\mtranspose, -20
		\mtranspose, 10
	)
).play; // returns an EventStream
//
)
//
Pdef(\pplay).stop;
//
currentEnvironment.postln;
//


(
//
~pan = Bus.control(s, 1);
~sb.map(\pan, ~pan);
y = {
	var pan;
	pan = (LFSaw.kr(\freq.kr(1)) + 1) / 2 * \mul.kr(1) + \add.kr(0);
	Out.kr(~pan, pan);
}.play(addAction: \addToHead);
//
)
//
y.free;
//
~pan.set(0.5);
~sb.set(\pan, 5/~nch);
~nch









(
//
Ndef(\piano_sb, {
	var out;
	out = OteySoundBoard.ar(
		In.ar(\in.kr(100), 1) // 100 --> later properly assign private bus here.
	);
	PanAz.ar(~nch, out, \pan.kr(0), 0.5, 2, 0.5);
}).play; //(0, ~nch);
//
Ndef(\piano_sb).set(\pan, 1/~nch);
currentEnvironment.postln;
Ndef(\piano_sb).set(\in, ~otey_bus);
//
SynthDef(\piano, {
	var out, env;
	env = EnvGen.ar(Env.asr(0,1,0.1), \gate.kr(1), doneAction:Done.freeSelf);
	out = OteyPianoStrings.ar(\freq.kr(440), \amp.kr(0.5), rho:\rho.kr(1)) * env;
	Out.ar(\out.kr(100), out); // 100 --> later properly assign private bus here.
}).add;
//
)

//lfo
Ndef(\lfo).mold(1, \control);
Ndef(\lfo, {(LFSaw.kr(\freq.kr(1)) + 1) / 2 * \mul.kr(1) + \add.kr(0)});
Ndef(\piano_sb) <<>.pan Ndef(\lfo);
Ndef(\lfo).set(\freq, 0.5);
Ndef(\lfo).set(\mul, 2);
Ndef(\lfo).set(\add, 0);











(
w=1;h=0.5;q=0.25;e=0.125;t=0.33;u=0.34;
c = TempoClock.default;
m = (
	chord: 0,
	scale: Scale([0,3,6,8,11,14,16],17),
	scaleChord: {
		|self,voicing|
		var notes = voicing + self.chord;
		Scale(self.scale.degrees.wrapAt(notes).sort, self.scale.pitchesPerOctave, self.scale.tuning);
	}
);
b = if (b.isNil,(),b);
f = if (f.isNil,(),f);
)

c.tempo = 1.5;

b.otey = Bus.audio(s,2);

(
SynthDef(\clang,
	{
		|freq=200,amp=0.1,gate=1,out=0,pan=0,boost=2,tapCarFreq=200,tapModFreq=200, tapPmIndex = 3, tapRatio = 0.5, releaseTime=0.6|
		var audio, chimeEnv, chimeFreqEnv, tap, tapEnv;
		chimeEnv = EnvGen.kr(Env([0,1,0.8,0],[0.001,0.005,releaseTime],[0,-2,-2]), gate, amp, doneAction:2);
		chimeFreqEnv = EnvGen.kr(Env([1,1.3,1],[0.005,0.005],[2,-2]), gate);
		audio = (1..20).collect({
			|num|
			var freqOffset, currentFreq, ampOffset, currentAmp;
			freqOffset = ((num * freq) % (num + 1)).linlin(0,num,0.95,1.05);
			ampOffset = ((num * freq) % (num + 2)).linlin(0,num+1,0.5,1) * TRand.kr(0.4,1.2,gate);
			currentFreq = num * freq * freqOffset * chimeFreqEnv;
			SinOsc.ar(currentFreq, 0, 0.1 * ampOffset);
		});
		audio = Mix(audio) * chimeEnv;
		tapEnv = EnvGen.kr(Env([0,1.1,0],[0.001,0.25],[0,-2]), gate, amp);
		tap = PMOsc.ar(freq.linlin(200,550,131.4,131.2) * tapCarFreq, tapModFreq, tapPmIndex, SinOsc.ar(130), tapEnv);
		audio = XFade2.ar(audio, tap, tapRatio);
		audio = (audio * boost).tanh / boost;
		audio = LPF.ar(audio, (freq * 10).min(10000));
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
SynthDef(\otey,
	{
		|in,out,gate=1|
		var audio,env;
		env = EnvGen.kr(Env.cutoff(5), gate, doneAction:2);
		audio = In.ar(in,2);
		audio = OteySoundBoard.ar(audio);
		Out.ar(out,audio);
	}
).add;
)
OteyPiano
(
f.otey.free;
f.otey = Synth(\otey, [\in, b.otey, \out, 0]);
)

(
Pdef(\clang,
	Pbind(
		\instrument, \clang,
		\octave, 4,
		\scale,Pfunc({m.scaleChord([0,2,4,6])}),
		\offset, Pstutter(Pwhite(5,20,inf),Pbrown(0,6,3,inf)),
		\degree, Pstutter(Pwrand([1,Pwhite(2,20,1)],[100,1].normalizeSum,inf),Pseq([0,1,2],inf) + Pkey(\offset)),
		//\degree, Pseq([0,4],inf),
		[\dur,\ampScale,\type, \tapRatio], Pwrand([
			Pseq([[q,0.1,\note, 0.2],[q,0.07,\note, 0.6]]),
			Pseq([[t/2,0.1,\note, 0.2],[t/2,0.05,\note, 0.8],[u/2,0.07,\note, 0.6]],Pwhite(1,3,1)),
			Pseq([[q/4,0.1,\note, 0.2],[q/4,0.1,\rest, 0.4],[q/4,0.03,\note, 0.7],[q/4,0.04,\note, 0.6]])
		],[10,1,3].normalizeSum,inf),
		\amp, Pkey(\ampScale) * 6 * Pgauss(1, 0.2,inf),
		\out,b.otey,
		\timingOffset, Pkey(\dur) * Pbrown(-0.1,0.1,0.04,inf),
		\tapCarFreq, 114,
		\tapModFreq, Pwhite(754,759,inf),
		\tapPmIndex, 1.9,
		\pan, Pkey(\degree).linlin(0,8,-0.8,0.5) + Pgauss(0,0.1,inf),
		\releaseTime, Pkey(\degree).linlin(0,8,0.8,0.6)
	)
).play;
)
Pdef(\clang).stop;











(
SynthDef(\prayer_bell, { |outbus, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, decayscale = 1, lag = 10, i_doneAction = 0|
  var sig, input, first, freqscale, mallet, sing;
  freqscale = freq / 2434;
  freqscale = Lag3.kr(freqscale, lag);
  decayscale = Lag3.kr(decayscale, lag);

  mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
  sing = LPF.ar(
    LPF.ar(
      {
        PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
      } ! 2,
      2434 * freqscale
    ) + Dust.ar(0.1), 10000 * freqscale
  ) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
  input = mallet + (sing_switch.clip(0, 1) * sing);


  sig = DynKlank.ar(`[
    [
      (first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
      first + LFNoise1.kr(0.5).range(1,3),
      LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
      LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
      LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
      LFNoise1.kr(2).range(8665, 8670),
      LFNoise1.kr(2).range(8704, 8709),
      LFNoise1.kr(2).range(8807, 8817),
      LFNoise1.kr(2).range(9570, 9607),
      LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
      LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
      LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
    ],
    [
      LFNoise1.kr(1).range(-10, -5).dbamp,
      LFNoise1.kr(1).range(-20, -10).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      -20.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp,
      -10.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp
    ],
    [
      20 * freqscale.pow(0.2),
      20 * freqscale.pow(0.2),
      5,
      5,
      0.6,
      0.5,
      0.3,
      0.25,
      0.4,
      0.5,
      0.4,
      0.6
    ] * freqscale.reciprocal.pow(0.5)
  ], input, freqscale, 0, decayscale);
  DetectSilence.ar(sig, doneAction: i_doneAction);
  Out.ar(outbus, sig);
}).add;
)


(
Pdef(\bell_1,
  Pmono(\prayer_bell,
    \dur, Pseq([8, 20], inf),
    \freq, Pseq([2500, 500], inf),
    \amp, 0.5,
    \lag, 0,
    \trig, Pseq([0.1], inf) * Pwhite(0.5, 1, inf) * Pwrand([0, 1], [1, 5].normalizeSum, inf),
    \sing_switch, Pseq((0!4) ++ (1!4), inf)
  )
);

Pdef(\bell_2,
  Pmono(\prayer_bell,
    \dur, Pwhite(8, 20, inf),
    \trig, Pwhite(0.05, 0.09),
    \sing_switch, Pwrand([0, 1], [5, 3].normalizeSum, inf),
    \freq, Prand((240, 360 .. 2000), inf),
    \amp, 0.5
  )
);

Pdef(\bell_3,
  Ppar([
    Pmono(\prayer_bell,
      \freq, 100,
      \dur, 1,
      \trig, 0,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5)
    ),
    Pmono(\prayer_bell,
      \freq, 200,
      \dur, 1,
      \trig, 0,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5)
    ),
    Pmono(\prayer_bell,
      \freq, 300,
      \dur, 1,
      \trig, 0,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5)
    )
  ])
);

Pdef(\bell_1).play;
Pdef(\bell_2).play;
Pdef(\bell_3).play;
)












Ndef(\bb).clear;


Ndef(\bbb).play(0, ~nch);
Ndef(\bbb).fadeTime = 2;
(
)
Ndef(\bbb).xset(\amp, 0.1);
Ndef(\bbb).xset(\midicps, 60);
Ndef(\bbb).clear;


//mousex
Ndef(\mousex).mold(1, \control);
Ndef(\mousex, {MouseX.kr(\min.kr(0), \max.kr(1), \wrap.kr(0), 0.2)});
Ndef(\aa) <<>.freq Ndef(\mousex);
Ndef(\mousex).set(\min, 100, \max, 5000);
//mousey
Ndef(\mousey).mold(1, \control);
Ndef(\mousey, {MouseY.kr(\min.kr(0), \max.kr(1), \wrap.kr(0), 0.2)});
Ndef(\aa) <<>.dectime Ndef(\mousey);
Ndef(\mousey).set(\min, 0.01,\max, 1);
//mousexy
Ndef(\mousexy).mold(2, \control);
m = Bus.control(2);
m.free
m = Bus(\control, 2);
m.subBus(0);
Ndef(\mousexy, {
	[
		MouseX.kr(\min.kr(0), \max.kr(1), \wrap.kr(0), 0.2),
		MouseY.kr(\min.kr(0), \max.kr(1), \wrap.kr(0), 0.2)
	]
});

Ndef(\mousex) <>>.dectime Ndef(\aa).subBus(0);
Ndef(\aa) <<>.freq Ndef(\mousexy);
Ndef(\mousexy).set(\min, 0.01,\max, 1);
Ndef(\aa) <<>.freq
[Ndef(\aa).freq, Ndef(\aa).dectime] <<> Ndef(\mousexy)
//lfo
Ndef(\lfo).mold(1, \control);
Ndef(\lfo, {(LFSaw.kr(\freq.kr(1)) + 1) / 2 * \mul.kr(1) + \add.kr(0)});
Ndef(\aa) <<>.freq Ndef(\lfo);
Ndef(\lfo).set(\freq, 0.05);
Ndef(\lfo).set(\mul, 1000);
Ndef(\lfo).set(\add, 300);

//
//
LFSaw.kr(MouseX.kr(0.1, 2, 'exponential'));
Ndef(\aa).xset(\damp, 0.2);
//
Ndef(\aa).xset(\amp, 1); //cross-fade..
Ndef(\aa).set(\amp, 10);

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
