


 //
// Title - Granular Workstation + GUI
// Author - Ashley Sagar
// Meanwood Audio Research And Recording
// AKA M/A/R/R/S
// date 10/05/2026

/*



What do I want to do???


// quite a lot of this code is firstly adapted from Bruno Ruviaro's Granular synthesis GYU demo
// from the SCCode website
// https://sccode.org/1-4UF

a new, mu;tiple granular synth/ loop player

6 audio slots.

with tools to effect each slot
a master effect
bus effects etc

*/


(
s.waitForBoot({

	var win, subwinA, masterWin;

	var soundFileViewA, soundFileViewB, soundFileViewC,soundFileViewD, soundFileViewE, soundFileViewF;

	var sfViewWidth =700, sfViewHeight=120, sfvY = 170;

	var openfileA,openfileB,openfileC,openfileD,openfileE,openfileF;

	var startButtonA;

	var soundFileA,soundFileB, soundFileC, soundFileD, soundFileE, soundFileF;

	var bufferA, bufferB, bufferC, bufferD, bufferE, bufferF;

	var synthAStart;

	// converts rate value -- taken from Bruno Ruviaro Granular synth
	var transpToRate = {arg transp; transp.linexp(-24,24,0.25, 4)};

	var trigSliderA, rateSliderA, durSliderA, panSliderA, ampSliderA;

	win = Window("Granular Workstation", Rect(0, 0, 1700,1100)).front;
	win.background=Color.green(0.2);
	win.onClose = {s.freeAll};



	// soundFile Views
	soundFileViewA = SoundFileView(win, Rect(10, 50, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);




	soundFileViewB = SoundFileView(win, Rect(10, 50+(sfvY), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewC = SoundFileView(win, Rect(10, 50+(sfvY*2), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewD = SoundFileView(win, Rect(10, 50+(sfvY*3), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewE = SoundFileView(win, Rect(10, 50+(sfvY*4), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewF = SoundFileView(win, Rect(10, 50+(sfvY*5), sfViewWidth, sfViewHeight)).gridOn_(true);



	// ---------- Master channel window

	masterWin = CompositeView(win, Rect(1350, 50, 300, 950))
	.background=Color.yellow(0.5);

	// --------- SynthA  Gui Controls ---------------------

	subwinA = CompositeView.new(win, Rect(sfViewWidth+(20), 50, sfViewWidth/1.15, sfViewHeight))
	.background=Color.yellow(0.3);
	// open buttons



	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileA = Button(subwinA, Rect(10, 10, 60, 30))
	.states_([["open file", Color.black, Color.gray]])
	.action_({
		"Hello".postln;
		startButtonA.value = 0;
		Dialog.openPanel(
			okFunc:{|path|
				soundFileA = SoundFile.new;
				soundFileA.openRead(path);
				// load soud into a buffer
				bufferA = Buffer.readChannel(s, path, channels: [0]);
				// display sound on view
				soundFileViewA.soundfile_(soundFileA);
				soundFileViewA.read(0, soundFileA.numFrames);

			},
			cancelFunc: {"cancelled"}
		);
	});


	//-----------------------------------------------------------------------



	// position slider



	// trigger range slider
	trigSliderA = EZRanger(
		parent: subwinA,
		bounds: Rect(90, 10, 500, 20),
		label: "trigger",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 150,
			warp: 'lin',
			step: 0.1,
			units: " t/s"
		),
	action: {|sl|
			if(startButtonA.value==1,
				{synthAStart.set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
		},
		initVal: [0.1,1],
		labelWidth: 50,
		unitWidth: 30
	)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);



	// rate slider
	rateSliderA = EZRanger(
		parent: subwinA,
		bounds: Rect(90, 35, 500, 20),
		label: "rate",
		controlSpec: ControlSpec(
			minval: -24,
			maxval: 24,
			warp: 'lin',
			step: 0.1,
			units: "ST"
		),
		action: {|sl|
			if(startButtonA.value ==1, {synthAStart.set(
				\rateLo, sl.lo,
				\rateHi, sl.hi)})
		},
		initVal: [0.3,1.5],
		labelWidth: 50,
		unitWidth: 30

	);


	// grain duration slider
	durSliderA = EZRanger(
		parent: subwinA,
		bounds: Rect(90, 55, 500, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 4,
			warp: 'lin',
			step: 0.1,
			units: "sec"
		),
		action: {|sl|
			if(startButtonA.value==1, {synthAStart.set(
				\durLo, sl.lo, \durHi, sl.hi)})},
		initVal: [0.01, 0.5],
		labelWidth: 50,
		unitWidth: 30);


	// pan position slider
	panSliderA = EZRanger(
		parent: subwinA,
		bounds: Rect(90, 75, 500, 20),
		label: "pan",
		controlSpec: ControlSpec(
			minval: -1,
			maxval: 1,
			warp: 'lin',
			step: 0.1,
			units: "L/R"
		),
		action: {|sl|
			if(startButtonA.value==1, {synthAStart.set(\panLo, sl.lo, \panHi, sl.hi)})
		},
		initVal: [-0.1,0.1],
		labelWidth: 50,
		unitWidth: 30
	);



	// ampslider - positioned on the master subwindow
	ampSliderA = EZRanger(
		parent: masterWin,
		bounds: Rect(10, 10, 30, 300),
		label: "amp",
		controlSpec: ControlSpec(
			minval:0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "amp"),
		action: {|sl|
			if(startButtonA.value==1, {synthAStart.set(\ampLo, sl.lo, \ampHi, sl.hi)})
		},
		initVal: [0.0,0.1],
		labelWidth: 30,
		unitWidth: 10,
		layout:'vert'
	);


	// start button
	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	startButtonA = Button(subwinA, Rect(10, 50,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ===1,
			{synthAStart = Synth(\grainA,
				[
					\triggerLo, trigSliderA.lo,
					\triggerHi, trigSliderA.hi,
					\rateLo, rateSliderA.lo,
					\rateHi, rateSliderA.hi,
					\durLo, durSliderA.lo,
					\durHi, durSliderA.hi,
					\panLo, panSliderA.lo,
					\panHi, panSliderA.hi,
					\ampLo, ampSliderA.lo,
					\ampHi, ampSliderA.hi,
					\bufnum, bufferA,


				]
			)},
			{synthAStart.free}
		)
	});







	// SynthDefs

	// synth A

	SynthDef(\grainA, {arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPos = 0.0, durLo, durHi, panLo, panHi, ampLo, ampHi ;


		var env, sig, trig, triggerAmount, rate, dur, pan, amp;


		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		sig = TGrains.ar(
			numChannels: 2,
			trigger: trig,
			bufnum: bufnum,
			rate: rate,
			centerPos: centerPos,
			dur: dur,
			pan: pan,
			amp: amp,
		);
		Out.ar(out, sig*env);
	}).add




})

)

