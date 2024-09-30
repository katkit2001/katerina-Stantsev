// 20171218 김다빈
// I used two audio samples 'StringsHigh.wav' and 'PercDry.wav'

// Buffer
~b = Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname +/+"/Samples/StringsHigh.wav", channels: 1);
~c = Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname +/+"/Samples/PercDry.wav", channels: 1);

// #1 Granular String Legato
(
SynthDef.new(\GranularStrLegato, {arg bufnum, amp=1.0;
	var tgrain, rateEnv, posEnv, ampEnv;

	rateEnv = EnvGen.kr(Env.new(
		// C: 0.5, C: 1, Ab : 1.6, Eb 1.2
		levels: [1.2, 2.4, 1.6, 1.6, 2.0, 2.0, 0.5, 0.5],
		times: [0.25, 0.25, 2.25, 0.25, 5, 0.5, 7.5],
		curve: [0, 0, 0, 1, 0, 0, 0]),
	1, levelScale: 1, doneAction: 2
	);
	posEnv = EnvGen.kr(Env.new(
		levels: [1.0, 0.7, 0.7, 1.3, 1.3],
		times: [0.5, 6.0, 2.0, 8.0],
		curve: [0, 0, 0, 0]),
	1, levelScale: 1, doneAction: 2
	);
	ampEnv = EnvGen.kr(Env.new(
		levels: [1.0, 1.0, 0.0],
		times: [8.0, 8.0],
		curve: [0, 1]),
	1, levelScale: 1, doneAction: 2
	);

	tgrain = TGrains.ar(numChannels: 2,
		trigger: Impulse.kr(50),
		bufnum: bufnum,
		rate: rateEnv,
		centerPos: posEnv,
		dur: 0.25,
		pan: WhiteNoise.kr(1),
		amp: amp,
		interp: 4
	);
	Out.ar(0, tgrain * ampEnv);
}).load(s);
)
Synth(\GranularStrLegato, [\buf, ~b.bufnum]);

// #2 Granular String Pad A
(
SynthDef.new(\GranularStrPadA, {arg bufnum, amp=1.0;
	var freq, tgrain, rateEnv, durEnv, ampEnv;

	rateEnv = EnvGen.kr(Env.new(
		levels: [0.5, 0.5, 1.6, 1.6, 1.2, 1.2],
		times: [12.0, 4.0, 4.0, 4.0, 8.0],
		curve: [0, -1, 0, -1, 0]),
	1, levelScale: 1, doneAction: 2
	);
	durEnv = EnvGen.kr(Env.new(
		levels: [1.25, 1.0, 0.5],
		times: [16.0, 16.0],
		curve: [1, -1]),
	1, levelScale: 1, doneAction: 2
	);
	ampEnv = EnvGen.kr(Env.new(
		levels: [0.0, 1.0, 1.0, 0.0],
		times: [8.0, 8.0, 16.0],
		curve: [0, 0, -1]),
	1, levelScale: 1, doneAction: 2
	);

	amp = amp * ampEnv;

	tgrain = TGrains.ar(numChannels: 2,
		trigger: Impulse.kr(100),
		bufnum: bufnum,
		rate: Dseq([0.4, 0.8, 0.6, 1.0, rateEnv, 2.0 * rateEnv], inf),
		centerPos: Drand([0, 0.1, 0.2, 0.3], inf),
		dur: Drand([1.0, 0.8, 0.6, 0.4], inf) * durEnv,
		pan: Drand([-1.0, -0.9, -0.7, -0.4, 0.0, 0.4, 0.7, 0.9, 1.0], inf),
		amp: Drand([1.0, 0.5, 0.3, 0.2, 0.1, 0.1, 0.5, 0.5], inf),
		interp: 4
	);
	Out.ar(0, tgrain * amp);
}).load(s);
)
Synth("GranularStrPadA", [\bufnum, b]);

// #3 Granular String Pad B
(
SynthDef("GranularStrPadB", {arg bufnum, amp=1, rate=1, gate=1;
	var grain, pitch, out, dur, posEnv, pitchEnv, ampEnv, trigger;

	dur = Drand([0.4, 0.5, 0.6], inf);
	posEnv = EnvGen.kr(Env.new(
		levels: [0.4, 0.4, 0.1, 0.4],
		times: [16.0, 16.0, 4.0],
		curve: [0, -1, 1]),
	1, levelScale: 1, doneAction: 2
	);
	pitchEnv = EnvGen.kr(Env.new(
		levels: [0.5, 0.5, 1.6, 1.6, 1.2, 1.2],
		times: [12.0, 4.0, 4.0, 4.0, 12.0],
		curve: [0, -1, 0, -1, 0]),
	1, levelScale: 1, doneAction: 2
	);
	ampEnv = EnvGen.kr(Env.new(
		levels: [0.0, 0.0, 1.0, 0.0],
		times: [16.0, 16.0, 4.0],
		curve: [0, -4, -1]),
	1, levelScale: 1, doneAction: 2
	);

	trigger = Impulse.kr(10);
	grain = GrainBuf.ar(2, trigger, dur, bufnum, rate, posEnv,
		interp: 2, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1
	);
	pitch = PitchShift.ar(in: grain,
		windowSize: 0.1, pitchRatio: pitchEnv, pitchDispersion: 0.3, timeDispersion: 2, mul: 1
	);

	out = Out.ar(0, Gate.ar(pitch, gate) * amp * ampEnv);
}).load(s);
)
Synth("GranularStrPadB",  [\sndbuf, b, \amp, 2, \rate, 3]);

// #5 Perc
(
SynthDef("GranularPerc", {arg sndbuf, rate = 1, pos=0, amp=1.0;
	var mix, rhpfMix, trigEnv, posEnv, durEnv, ampEnv, out, trigger, posM;

	trigEnv = EnvGen.kr(Env.new(
		levels: [15, 15, 10, 1],
		times: [16.0, 8.0, 16.0],
		curve: [0, -2, 1]),
	1, levelScale: 1, doneAction: 2
	);
	posEnv = EnvGen.kr(Env.new(
		levels: [0.2, 0.2, -0.02, 0.00, 0.04],
		times: [14.0, 4.0, 6.0, 16.0],
		curve: [0, -2, -1, 1]),
	1, levelScale: 1, doneAction: 2
	);
	durEnv = EnvGen.kr(Env.new(
		levels: [0.1, 0.1, 0.3, 0.1, 0.5],
		times: [16.0, 4.0, 4.0, 16.0],
		curve: [0, 2, 0]),
	1, levelScale: 1, doneAction: 2
	);
	ampEnv = EnvGen.kr(Env.new(
		levels: [0.0, 0.0, amp, amp, 0.0],
		times: [12.0, 4.0, 16.0, 8.0],
		curve: [0, 2, 0]),
	1, levelScale: 1, doneAction: 2
	);

	trigger = Impulse.kr(trigEnv);
	posM = posEnv;    /*MouseY.kr(-0.03, 0.5);*/
	mix = GrainBuf.ar(2, trigger, durEnv, sndbuf, rate, posM, 2, 0, -1, 512, 0.3);
	rhpfMix = RHPF.ar(in: mix, freq: 25.0, rq: 0.8, mul: 1.0, add: 0.0);
	out = Out.ar(0, Pan2.ar(rhpfMix, pos) * ampEnv);
}).load(s);
)
Synth("GranularPerc", [\rate, 0.8, \sndbuf, ~c, \pos, 0, \amp, 0.5]);


// Effects
(
SynthDef("delay", {arg volume = 1.0;
	var input, delay, output;
	input = In.ar(0);
	delay = CombC.ar(input, maxdelaytime: 1.0, delaytime: 0.3, decaytime: 0.5, mul: 1.0, add: 0.0);
	output = Out.ar([0,1], delay * volume);
}).load(s);

SynthDef("reverb", {arg mix=0.3, room=0.7, damp=0.5, volume=1.0;
	var input, reverb, output;
	input = In.ar([0,1]);
	reverb = FreeVerb.ar(input, mix, room, damp);
	output = Out.ar([0,1], reverb * volume);
}).load(s);

SynthDef("rhpfReverb", {arg mix=0.3, freq=1380, rq=0.7, room=0.7, damp=0.5, volume=1.0;
	var input, rhpfMix, reverb, output;
	input = In.ar([0,1]);
	rhpfMix = RHPF.ar(in: input, freq: freq, rq: rq, mul: 1.0, add: 0.0);
	reverb = FreeVerb.ar(rhpfMix, mix, room, damp);
	output = Out.ar([0,1], reverb * volume);
}).load(s);
)

(
// Group 1 : StrLegato
// Track 1 : StrLegato
{
~groupStrLegato = Group.new(target: s, addAction: \addToHead);
~sourceStrLegato = Synth("\GranularStrLegato",
	[\bufnum, ~b], target: ~groupStrLegato, addAction: \addToHead);
~delayStrLegato = Synth("delay",
	[\volume, 0.3], target: ~sourceStrLegato, addAction: \addAfter);

// Group 2 : GranularStrPad
~groupGranularStrPad = Group.new(target: s, addAction: \addAfter);
// Track 2 : GranularStrPadA
~groupGranularStrPadA = Group.new(target: ~groupGranularStrPad, addAction: \addToHead);
~sourceGranularStrPadA = Synth("GranularStrPadA",
	[\bufnum, ~b, \amp, 1.3], target: ~groupGranularStrPadA, addAction: \addToHead);

// Track 3 : GranularStrPadB
~groupGranularStrPadB = Group.new(target: ~groupGranularStrPadA, addAction: \addAfter);
~sourceGranularStrPadB = Synth("GranularStrPadB",
	[\sndbuf, ~b, \amp, 1.5, \rate, 4], target: ~groupGranularStrPadB, addAction: \addToHead);
~delayGranularStrPadB = Synth("delay",
	[\volume, 0.3], target: ~sourceGranularStrPadB, addAction: \addAfter);

~reverbGranularStrPad = Synth("reverb",
	[\mix, 1.0, \room, 0.5, \damp, 0.5, \volume, 0.5], target: ~groupGranularStrPad, addAction: \addToTail);

// Group 3 : GranularPerc
// Track 4 : GranularPerc
~groupGranularPerc = Group.new(target: ~groupGranularStrPad, addAction: \addAfter);
~sourceGranularPerc = Synth("GranularPerc",
		[\rate, 0.8, \sndbuf, ~c, \pos, 0, \amp, 0.7], target: ~groupGranularPerc, addAction: \addToHead);
~rhpfReverbGranularPerc = Synth("rhpfReverb",
		[\mix, 1, \freq, 850, \rq, 0.7, \room, 0.7, \damp, 0.5, \volume, 0.3],
target: ~sourceGranularPerc, addAction: \addAfter);


s.queryAllNodes;
}.defer(1);

// Recorder
/*r = Recorder.new(s);
r.record(duration: 50);*/
)

s.free;
