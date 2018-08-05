/*
	*
	* a supercollider sound & music server for scroll-link-server
	*
	* dhy @ dianaband @ 2018. 07. 28.
	*
*/

//// NOTES

// multichannel expansion won't happen on the fly.
//
// SynthDef's are to be 'compiled' on the server.
//
// ME is a feature of compilation: actively producing many UGens when it is needed.
// control messages by 'set' is directed to the 'already existing' UGen.
// so triggering ME expansion after 'compilation step' is non-sense: simply won't happen.

// so, we ought to define ~nchannels specifically.
// then, use it wisely to trigger ME when it is being created. (Synth messages)

// then, we can SynthDef freely? or SynthDef should be done already ME done?
// well. manual says that it is not possible to ME on 'creation'..

~nchannels = 2;

SynthDef(\sine, {
	arg ibs, obs=[1,0], mul=1, freq=440;
	Out.ar(obs, {
		SinOsc.ar(freq, mul:mul);
	});
}).add;

SynthDef(\gain, {
    arg ibs, obs, mul=1;
    Out.ar(obs, {
        In.ar(ibs, ~nchannels) * mul
    });
}).add;

s.queryAllNodes;
Server
~sine = Synth.new(\sine, [\obs, [0, 1]]);
g = Bus.audio(s, ~nchannels);
~gain = Synth.after(~tball, \gain, [\ibs, t, \obs, g]);


// The makeEffect function below wraps a simpler function within itself and provides
// a crossfade into the effect (so you can add it without clicks), control over wet
// and dry mix, etc.
// Such functionality is useful for a variety of effects, and SynthDef-wrap
// lets you reuse the common code.
(
// the basic wrapper
~makeEffect = {

	arg name, func, lags, numChannels = 2;

    SynthDef(name, {

		arg i_bus = 0, gate = 1, wet = 1;
        var in, out, env, lfo;

        in = In.ar(i_bus, numChannels);
        env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect

        // call the wrapped function. The in and env arguments are passed to the function
        // as the first two arguments (prependArgs).
        // Any other arguments of the wrapped function will be Controls.
        out = SynthDef.wrap(func, lags, [in, env]);

        XOut.ar(i_bus, wet * env, out);

    }, [0, 0, 0.1] ).add;

};
)

// now make a wah
(
~makeEffect.value(\wah, {|in, env, rate = 0.7, ffreq = 1200, depth = 0.8, rq = 0.1|
    // in and env come from the wrapper. The rest are controls
     var lfo;
    lfo = LFNoise1.kr(rate, depth * ffreq, ffreq);
    RLPF.ar(in, lfo, rq, 10).distort * 0.15; },
    [0.1, 0.1, 0.1, 0.1],  // lags for rate ffreq, depth and rq
    2    // numChannels
);
)

// now make a simple reverb
(
~makeEffect.value(\reverb, {|in, env|
    // in and env come from the wrapper.
    var input;
    input = in;
    16.do({ input = AllpassC.ar(input, 0.04, Rand(0.001,0.04), 3)});
    input; },
    nil,  // no lags
    2    // numChannels
);
)

// something to process
x = { {Decay2.ar(Dust2.ar(3), mul: PinkNoise.ar(0.2))} ! 2}.play;

y = Synth.tail(s, \wah);
z = Synth.tail(s, \reverb, [\wet, 0.5]);

// we used an arg named gate, so Node-release can crossfade out the effects
y.release;

// setting gate to zero has the same result
z.set(\gate, 0);

x.free;
