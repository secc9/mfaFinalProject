


// learn how to make  a bus
// using the cottle book

s.plotTree

s.boot
s.meter




"/Users/ashleysagar/Music/SuperCollider/Tutorials/EliFieldsteel/Week-06_Lecture-Code_2021-09-30.scd"






s.boot
(
SynthDef(\sound, {|out=0,gate=1|
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, 0.1),gate,doneAction: 2);
	sig = WhiteNoise.ar(1);
	Out.ar(out, sig*LFPulse.kr(0.5))
}).add;

SynthDef(\verb, {|in=0,out=0|
	var sig, effect;
	sig = In.ar(in, 2);
	effect = FreeVerb2.ar(
		sig[0], sig[1],
	);
	sig = sig + effect;
	Out.ar(out, sig)

}).add;

)
a = Synth(\sound, [\out,12 ])
b = Synth(\verb, [\in, 12, ])


1

(
SynthDef(\randSine, {|rate=9,scale-300,offset=600,pan=0,out|
	out=Pan2.ar(SinOsc.ar(LFNoise0.ar(rate, scale, offset),mul: 0.3),pan);
	DetectSilence.ar(out, doneAction: 2);
	Out.ar(0, out)
}).add
)

a = Synth(\randSine, [\pan, -1, \rate, 8])
b = Synth(\randSine, [\pan, 1, \rate, 13])
b.set(\offset, 2000)
a.set(\rate, 20)
b.set(\rate, 6)
a.set(\scale, 550)
a.free
b.free

s.meter(2,8)
{Out.ar(5,SinOsc.ar)}.play
{In.ar([2, 3])}.play



(
{
	[
		SinOsc.ar,
		PinkNoise.ar,
		LFNoise0.ar,
		LFNoise1.ar,
		LFTri.ar,
		WhiteNoise.ar
	]*0.4
}.scope

)


(
{
	[
		SinOsc.kr(100),
		Dust.kr(50),
		Impulse.kr(78),
		LFNoise0.kr(100),
		LFNoise1.kr(100),
		WhiteNoise.kr
	]*0.4
}.scope(zoom:10)
)

{SinOsc.ar(LFNoise0.kr([10, 15])*400+800, 0, 0.3)}.scope

{SinOsc.ar(800, 0, 0.3)}.scope

{LFNoise0.ar([10, 15])}.scope


{Out.ar(0, SinOsc.ar(800, 0, 0.3))}.scope


{Out.ar(5, SinOsc.ar(800, 0, 0.3))}.scope(16)

{Out.kr(9, LFNoise0.kr([10, 15], 1, 0))}.scope(16, zoom:10)


{Out.kr(20, LFNoise0.kr([8, 11], 500, 1000))}.scope

{Out.ar(0, SinOsc.ar(In.kr(20, 2), 0, 0.3))}.scope





(
SynthDef(\lfn0Control, {
	Out.kr(20, LFNoise0.kr([8,11], 500, 1000))
}).play(s);

SynthDef(\sineControl, {
	Out.kr(22, SinOsc.kr([3, 3.124], mul:500,add: 1000))
}).play(s);

SynthDef(\mouseControl, {
	Out.kr(24, MouseX.kr([100, 200],1000))
}).play(s);

a = SynthDef(\patchableSine,{
	arg busInNum = 0;
	Out.ar(0, SinOsc.ar(In.kr(busInNum, 2), 0, 0.3))
}).play(s);
)

a.set(\busInNum, 23)
a.set(\busInNum, 22)
a.set(\busInNum, 24)
a.free


a = Synth(\patchableSine, [\busInNum, 20]); b = Synth(\lfn0Control)
b.free; b = Synth(\sineControl); a.set(\busInNum,22)


(
SynthDef(\sendControl1, {
	Out.kr(0, SinOsc.ar(0.3, mul: 1000,add: 1100))}).send(s);
SynthDef(\sendControl2,{Out.kr(0, LFNoise0.ar(12, 200, 500))}).send(s);
SynthDef(\receive,{Out.ar(0, SinOsc.ar(In.kr(0)))}).send(s)
)

Synth(\receive)
Synth(\sendControl1)
Synth(\sendControl2)

(
SynthDescLib.global.read;
SynthDescLib.global.browse;
)




(
SynthDef(\saw, {arg filterBus=16;
	Out.ar(filterBus, LFSaw.ar([60, 90]))}).add;

SynthDef(\filter, {arg filterBus=16;
	Out.ar(0, RLPF.ar(In.ar(filterBus, 2), LFNoise0.kr(12, 300,350),0.2))
}).add;
)

Synth(\saw)
Synth(\filter)


s.boot;s.meter;s.scope
 b = Bus.audio
b.index
b.free
c = Bus.audio(s, 2)
b = Bus.audio(s,2)

s.meter;s.scope
{Out.ar(c.index, Saw.ar)}.play
{Out.ar(b.index, SinOsc.ar([500, 1000]))}.scope(8)
c.free;d.free

{Out.ar(4, SinOsc.ar([100, 200,300,400]))}.scope(8)
b = Bus.audio(s, 2)
b.index

{Out.ar(b.index, Saw.ar([800, 1000]))}.scope(8)
b.free
s.boot

a = Bus.audio(s, 2)
b = Bus.audio(s, 1);
c = Bus.audio(s, 2)
c.index
a.index
b.index
a.free
b.free
d = Bus.audio(s, 1)
e = Bus.audio(s, 2)
a = Bus.audio(s, 2)
b = Bus.audio(s, 1)

[a, b, c, d, e].postln
s.scope(14)
Bus.free


{Out.ar(0, Mix.ar(In.ar(2,12))*0.1)}.play
{Out.ar(a.index, SinOsc.ar)}.play
{Out.ar(b.index, SinOsc.ar(1000))}.play
{Out.ar(c.index, Saw.ar([400, 800]))}.play
{Out.ar(d.index, Pulse.ar(200))}.play
{Out.ar(e.index, [Saw.ar(500), FSinOsc.ar(900)])}.play


[a,b,c,d,e].do({arg each; each.free})







