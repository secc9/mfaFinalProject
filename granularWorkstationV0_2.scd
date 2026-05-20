


 //
// Title - Granular Workstation + GUI
// Author - Ashley Sagar
// Meanwood Audio Research And Recording
// AKA M/A/R/R/S
// date 10/05/2026

/*



What do I want to do???


// quite a lot of this code is heavily adapted from Bruno Ruviaro's Granular synthesis GUI demo
// from the SCCode website
// https://sccode.org/1-4UF

a new, multiple granular synth/ loop player

 * TODO
6 audio slots.
  - make 1 granular synth first, then add in the 5
  - add a level meter on the Subwindows
  - I have space at the bottom. maybe some effect dials>>>>?????
  - add a type button >> switches the type of file player
     - TGrains - GrainBuf - Warp1 - PlayBuf - RecBuf

- master view window

  - maybe add in a scope
  - add in a level
  - add in the volume sliders for each loop player
  - do I want Auxillary sends???? here?????


with tools to effect each slot
a master effect
bus effects etc

*/


(
s.waitForBoot({

	var win, subwinA, masterWin, posSilderViewA,posSilderViewB,posSilderViewC,posSilderViewD,posSilderViewE,posSilderViewF;


	// containers for the composite loop/grain views
	var controlStackA, grainControlViewA, loopControlViewA, controlAreaA;



	var selectSwitchA;

	var soundFileViewA, soundFileViewB, soundFileViewC,soundFileViewD, soundFileViewE, soundFileViewF;

	var sfViewWidth =700, sfViewHeight=100, sfvYPos = 50, sfvY = 170; // view positions

	var openfileA,openfileB,openfileC,openfileD,openfileE,openfileF;

	var startButtonA;

	var soundFileA,soundFileB, soundFileC, soundFileD, soundFileE, soundFileF;

	var bufferA, bufferB, bufferC, bufferD, bufferE, bufferF;

	var synthAStart;

	// converts rate value -- taken from Bruno Ruviaro Granular synth
	var transpToRate = {arg transp; transp.linexp(-24,24,0.25, 4)};

	var loopTrigSliderA,grainTrigSliderA, rateSliderA, durSliderA, panSliderA, ampSliderA;

	var rangerXpos = 70, rangerWidth=450;




	var centerPosInSecondsA, centerPosSliderA, selectionSpec, soundFile;


	var masterMeter, scope;


	// this block taken from from Bruno Ruviaro Granular synth
	// convert from centerPosSlider values (0-1)
	// to actual sound file position in seconds
	centerPosInSecondsA = {
		[
			centerPosSliderA.lo.linlin(0, 1, 0, soundFileA.duration),
			centerPosSliderA.hi.linlin(0, 1, 0, soundFileA.duration)
		] // returns an array [lo, hi]
	};



	Buffer.freeAll; //free all buffers before loading


	// make a window
	win = Window("Granular Workstation", Rect(0, 0, 1700,1100)).front;
	win.background=Color.green(0.2);
	win.onClose = {
		masterMeter.remove; // kills server meter
		masterMeter = nil;

		SystemClock.sched(0.1, { s.freeAll; nil});
	};



	//----------------------------------------------------------------
	//------------------- soundFile Views ----------------------------
	//----------------------------------------------------------------




	soundFileViewB = SoundFileView(win, Rect(10, sfvYPos+(sfvY), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewC = SoundFileView(win, Rect(10, sfvYPos+(sfvY*2), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewD = SoundFileView(win, Rect(10, sfvYPos+(sfvY*3), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewE = SoundFileView(win, Rect(10, sfvYPos+(sfvY*4), sfViewWidth, sfViewHeight)).gridOn_(true);
	soundFileViewF = SoundFileView(win, Rect(10, sfvYPos+(sfvY*5), sfViewWidth, sfViewHeight)).gridOn_(true);


	//------------Position Slider Views ----------------------------

	posSilderViewA = CompositeView(win, Rect(10, 155, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewB = CompositeView(win, Rect(10, 325, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewC = CompositeView(win, Rect(10, 495, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewD = CompositeView(win, Rect(10, 665, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewE = CompositeView(win, Rect(10, 835, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewF = CompositeView(win, Rect(10, 1005, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	// ---------- Master channel window ------------------------------

	masterWin = CompositeView(win, Rect(1350, 50, 300, 950))
	.background=Color.yellow(0.5);



	//----------------------------------------------------------------
	//---------------------- Synth A view ----------------------------
	//----------------------------------------------------------------


	// --------- SynthA  Gui window ---------------------

	subwinA = CompositeView(win, Rect(sfViewWidth+(20), 50, sfViewWidth/1.15, sfViewHeight+45))
	.background=Color.yellow(0.3);


	// container for the loop and grain control gui window

	loopControlViewA = CompositeView(subwinA, Rect(0, 0, sfViewWidth/1.15, sfViewHeight+45));
	loopControlViewA.background = Color.clear;
	loopControlViewA.visible_(false);

	grainControlViewA = CompositeView(subwinA, Rect(0, 0, sfViewWidth/1.15, sfViewHeight+45));
	grainControlViewA.background=Color.clear;
	grainControlViewA.visible_(true);

	// create stackLayout
	// controlStackA = StackLayout(loopControlViewA, grainControlViewA);

	// create container with fixed position
	controlAreaA = CompositeView(subwinA, Rect(sfViewWidth+(20), 50, sfViewWidth/1.15, sfViewHeight+45))
	.background=Color.grey(0.2);

	controlAreaA.layout = controlStackA;

	//------------------- soundFileViewA window----------------------------
	soundFileViewA = SoundFileView(win, Rect(10, 50, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
	soundFileViewA.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpec.unmap(loFrames);
		hiSlider = selectionSpec.unmap(hiFrames);
		2.do{centerPosSliderA.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};




	// function for the grain view to live inside a stack view

	//------------------- gui controls -------------------------
	// open buttons

	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileA = Button(subwinA, Rect(5, 50, 60, 30))
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

				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpec = ControlSpec(0, soundFileA.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewA.setSelection(0, selectionSpec.map([0.1, 0.2]));
				// Update slider
				soundFileViewA.mouseUpAction.value(soundFileViewA);

			},
			cancelFunc: {"cancelled"}
		);
	});

	//-----------------------------------------------------------------------

	// position slider
	centerPosSliderA = RangeSlider(posSilderViewA, Rect(10, 5,sfViewWidth-20, 30 ))
	.lo_(0.1)
	.hi_(0.9)
	.action_({|sl|
		var lo, hi, size;
		lo = selectionSpec.map(sl.lo);
		hi = selectionSpec.map(sl.hi);
		size = hi - lo;
		soundFileViewA.setSelection(0, [lo, size]);
		if(startButtonA.value==1, {synthAStart.set(
			\centerPosLo, centerPosInSecondsA.value[0],
			\centerPosHi, centerPosInSecondsA.value[1]
		)});
	});

	//------------- synth select button ------------------

	selectSwitchA = Button(subwinA, Rect(5, 10, 60, 30))
	.states_([["GRAIN", Color.black, Color.cyan], ["LOOP", Color.black, Color.blue]])
	.action_({|button|

		    // Show/hide the appropriate panel
    loopControlViewA.visible = (button.value == 1);
    grainControlViewA.visible = (button.value == 0);

		if(startButtonA.value==1,{
			synthAStart.set(\playmode, button.value)
		});
	});


	//-----------------------------------------------------------------------

	//---------------------LOOP CONTROLS -----------------------------------

	loopTrigSliderA = EZRanger(
		parent: loopControlViewA,
		bounds: Rect(rangerXpos, 10, rangerWidth, 20),
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
	);



	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	grainTrigSliderA = EZRanger(
		parent: grainControlViewA,
		bounds: Rect(rangerXpos, 10, rangerWidth, 20),
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
	);
	// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

//-----------------------------------------------------------------------

	// rate slider
	rateSliderA = EZRanger(
		parent: grainControlViewA,
		bounds: Rect(rangerXpos, 30, rangerWidth, 20),
		label: "rate",
		controlSpec: ControlSpec(
			minval: -2,
			maxval: 12,
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
//-----------------------------------------------------------------------

	// grain duration slider
	durSliderA = EZRanger(
		parent: grainControlViewA,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
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

//-----------------------------------------------------------------------
	// pan position slider
	panSliderA = EZRanger(
		parent: grainControlViewA,
		bounds: Rect(rangerXpos, 70, rangerWidth, 20),
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


//-----------------------------------------------------------------------
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
			units: "dB"),
		action: {|sl|
			if(startButtonA.value==1, {synthAStart.set(\ampLo, sl.lo, \ampHi, sl.hi)})
		},
		initVal: [0.01,0.1],
		labelWidth: 30,
		unitWidth: 10,
		layout:'vert'
	);








//-----------------------------------------------------------------------
	// start button
	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	startButtonA = Button(subwinA, Rect(5, 90,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ==1,
			{synthAStart = Synth(\grainA,
				[
					\playMode, selectSwitchA.value,
					\triggerLo, grainTrigSliderA.lo,
					\triggerHi, grainTrigSliderA.hi,
					\rateLo, transpToRate.value(rateSliderA.lo),
					\rateHi, transpToRate.value(rateSliderA.hi),
					\centerPosLo, centerPosInSecondsA.value[0],
					\centerPosHi, centerPosInSecondsA.value[1],
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







	/*stackA = StackLayout(

	);*/


//-----------------------------------------------------------------------





	// SynthDefs

	// synth A

	SynthDef(\grainA, {
		arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi, playMode=0 ;


		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;


		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

		grainSig = TGrains.ar(
			numChannels: 2,
			trigger: trig,
			bufnum: bufnum,
			rate: rate,
			centerPos: centerPos,
			dur: dur,
			pan: pan,
			amp: amp,
		);

		loopSig = PlayBuf.ar(
			numChannels:2,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum)+rate,
			trigger: trig,
			loop: 1,
		);



		sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, sig*env);
	}).add;










	//  masterserver meter

	masterMeter = ServerMeterView(s, masterWin,210@720, 0, 2 );

	// scope

	/*scope = ScopeView(masterWin, Rect(20, 730, 180, 200))
	.bufnum=bufferA;
	scope = s;*/



})

)

