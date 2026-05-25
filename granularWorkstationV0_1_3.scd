


 //
// Title - Granular Workstation + GUI
// Author - Ashley Sagar
// Meanwood Audio Research And Recording
// AKA M/A/R/R/S
// date 10/05/2026

/*


******* V_0_1_3
// quite a lot of this code is heavily adapted from Bruno Ruviaro's Granular synthesis GUI demo
// from the SCCode website
// https://sccode.org/1-4UF


What do I want to do???




a new, multiple granular synth/ loop player/ record

 * TODO
6 audio slots.
  -// make 1 granular synth first, then add in the 5 - This now (20/05/26) - DONE - 22/05/26
  - add a level meter on the Subwindows
  - I have space at the bottom of each player control subwindow. maybe some effect dials>>>>?????




- add a type button >> switches the type of file player
     - TGrains - GrainBuf - Warp1 - PlayBuf - RecBuf

- master view window

  - maybe add in a scope
  - add in a level - Done
  - add in the volume sliders for each loop player - Done - 22/05/26
  - do I want Auxillary sends???? here?????
  - OK. Sends - I need to figure out how sends work. it's been a long time
    - Reverb
    - Delay
      - TODO
        - Build synthdef for reverb
        - Build Delay


  -  with tools to effect each slot
  -  a master effect
  -  bus effects etc
  - multiple channels out????????????? this would be nice
record to disk function

*/


(
s.waitForBoot({

	var win, subwinA, subwinB,subwinC,subwinD,subwinE,subwinF, masterWin, posSilderViewA,posSilderViewB,posSilderViewC,posSilderViewD,posSilderViewE,posSilderViewF;


	// containers for the composite loop/grain views



	var soundFileViewA, soundFileViewB, soundFileViewC,soundFileViewD, soundFileViewE, soundFileViewF;

	var sfViewWidth =700, sfViewHeight=100, sfvYPos = 40, sfvY = 170; // view positions

	var openfileA,openfileB,openfileC,openfileD,openfileE,openfileF;

	var startButtonA,startButtonB,startButtonC,startButtonD,startButtonE,startButtonF;

	var soundFileA,soundFileB, soundFileC, soundFileD, soundFileE, soundFileF;

	var bufferA, bufferB, bufferC, bufferD, bufferE, bufferF;

	var synthAStart,synthBStart,synthCStart,synthDStart,synthEStart,synthFStart;

	// converts rate value -- taken from Bruno Ruviaro Granular synth
	var transpToRate = {arg transp; transp.linexp(-24,24,0.25, 4)};

	var trigSliderA, rateSliderA, durSliderA, panSliderA, ampSliderA;
	var trigSliderB, rateSliderB, durSliderB, panSliderB, ampSliderB;
	var trigSliderC, rateSliderC, durSliderC, panSliderC, ampSliderC;
	var trigSliderD, rateSliderD, durSliderD, panSliderD, ampSliderD;
	var trigSliderE, rateSliderE, durSliderE, panSliderE, ampSliderE;
	var trigSliderF, rateSliderF, durSliderF, panSliderF, ampSliderF;

	var rangerXpos = 70, rangerWidth=450;




	var centerPosInSecondsA, centerPosSliderA, selectionSpecA;
	var centerPosInSecondsB, centerPosSliderB, selectionSpecB;
	var centerPosInSecondsC, centerPosSliderC, selectionSpecC;
	var centerPosInSecondsD, centerPosSliderD, selectionSpecD;
	var centerPosInSecondsE, centerPosSliderE, selectionSpecE;
	var centerPosInSecondsF, centerPosSliderF, selectionSpecF;


	var masterMeter, scope;

	/*var verbBus = Bus.audio(s, 2);
	var delayBus = Bus.audio(s, 2);*/

	var busReverb, busDelay, verbAmpSlider, delayAmpSlider;
	var verbView, delayView;
	var verbMix, verbRoom, verbDamp, delayTime, decayTime;


	// this block taken from from Bruno Ruviaro Granular synth
	// convert from centerPosSlider values (0-1)
	// to actual sound file position in seconds
	centerPosInSecondsA = {
		[
			centerPosSliderA.lo.linlin(0, 1, 0, soundFileA.duration),
			centerPosSliderA.hi.linlin(0, 1, 0, soundFileA.duration)
		] // returns an array [lo, hi]
	};

	centerPosInSecondsB = {
		[
			centerPosSliderB.lo.linlin(0, 1, 0, soundFileB.duration),
			centerPosSliderB.hi.linlin(0, 1, 0, soundFileB.duration)
		] // returns an array [lo, hi]
	};

	centerPosInSecondsC = {
		[
			centerPosSliderC.lo.linlin(0, 1, 0, soundFileC.duration),
			centerPosSliderC.hi.linlin(0, 1, 0, soundFileC.duration)
		] // returns an array [lo, hi]
	};

	centerPosInSecondsD = {
		[
			centerPosSliderD.lo.linlin(0, 1, 0, soundFileD.duration),
			centerPosSliderD.hi.linlin(0, 1, 0, soundFileD.duration)
		] // returns an array [lo, hi]
	};

	centerPosInSecondsE = {
		[
			centerPosSliderE.lo.linlin(0, 1, 0, soundFileE.duration),
			centerPosSliderE.hi.linlin(0, 1, 0, soundFileE.duration)
		] // returns an array [lo, hi]
	};

	centerPosInSecondsF = {
		[
			centerPosSliderF.lo.linlin(0, 1, 0, soundFileF.duration),
			centerPosSliderF.hi.linlin(0, 1, 0, soundFileF.duration)
		] // returns an array [lo, hi]
	};



	Buffer.freeAll; //free all buffers before loading


	// make a window
	win = Window("Granular Workstation",
		Rect(0, 0, Window.screenBounds.width,Window.screenBounds.height);
	).front;
	"Hi. Welcome to the Meanwood Audio Granular Workstation".postln;
	win.background=Color.green(0.2);
	win.onClose = {
		masterMeter.remove; // kills server meter
		masterMeter = nil;
		"Thanks for your time. Goodbye".postln;

		SystemClock.sched(0.1, { s.freeAll; nil});
	};










	//------------Position Slider Views ----------------------------

	posSilderViewA = CompositeView(win, Rect(10, 115, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewB = CompositeView(win, Rect(10, 285, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewC = CompositeView(win, Rect(10, 455, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewD = CompositeView(win, Rect(10, 625, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewE = CompositeView(win, Rect(10, 795, sfViewWidth, 40))
	.background = Color.yellow(0.5);
	posSilderViewF = CompositeView(win, Rect(10, 965, sfViewWidth, 40))
	.background = Color.yellow(0.5);






	// ---------- Master channel window ------------------------------

	masterWin = CompositeView(win, Rect(1270, 10, 440, 995))
	.background=Color.yellow(0.5);



	//----------------------------------------------------------------
	//---------------------- Synth A view ----------------------------
	//----------------------------------------------------------------


	// --------- SynthA  Gui window ---------------------

	subwinA = CompositeView.new(win, Rect(sfViewWidth+(20), 10, sfViewWidth/1.3, sfViewHeight+45))
	.background=Color.yellow(0.3);



	//------------------- soundFileViewA window----------------------------
	soundFileViewA = SoundFileView(win, Rect(10, 10, sfViewWidth, sfViewHeight))
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
		loSlider = selectionSpecA.unmap(loFrames);
		hiSlider = selectionSpecA.unmap(hiFrames);
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
		"Hello, Why don't you find yourself a sample or a soundfile to play in Player A".postln;
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
				selectionSpecA = ControlSpec(0, soundFileA.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewA.setSelection(0, selectionSpecA.map([0.1, 0.2]));
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
		lo = selectionSpecA.map(sl.lo);
		hi = selectionSpecA.map(sl.hi);
		size = hi - lo;
		soundFileViewA.setSelection(0, [lo, size]);
		if(startButtonA.value==1, {synthAStart.set(
			\centerPosLo, centerPosInSecondsA.value[0],
			\centerPosHi, centerPosInSecondsA.value[1]
		)});
	});




	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	trigSliderA = EZRanger(
		parent: subwinA,
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
		parent: subwinA,
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
		parent: subwinA,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 40,
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
		parent: subwinA,
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
		label: "ch1",
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

					\triggerLo, trigSliderA.lo,
					\triggerHi, trigSliderA.hi,
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
					// \out, verbBus,

		"Player A is playing".postln;
				]
			)},
			{
				synthAStart.set(\gate, 0);
				if(startButtonA==0,{
					synthAStart.free});
						"Player A has stopped".postln;
			}
		);

	});

      //----------------------------------------------------------------
	//---------------------- Synth A view END ----------------------------
	//----------------------------------------------------------------
      //-----------------------------------------------------------------------

	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------


	//----------------------------------------------------------------
	//---------------------- Synth B view ----------------------------
	//----------------------------------------------------------------


	// --------- SynthB  Gui window ---------------------

	subwinB = CompositeView.new(win, Rect(sfViewWidth+(20), 180, sfViewWidth/1.3, sfViewHeight+45))
	.background=Color.yellow(0.3);



	//------------------- soundFileViewB window----------------------------
	soundFileViewB = SoundFileView(win, Rect(10, 180, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
	soundFileViewB.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpecB.unmap(loFrames);
		hiSlider = selectionSpecB.unmap(hiFrames);
		2.do{centerPosSliderB.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};


	// function for the grain view to live inside a stack view

	//------------------- gui controls -------------------------
	// open buttons

	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileB = Button(subwinB, Rect(5, 50, 60, 30))
	.states_([["open file", Color.black, Color.gray]])
	.action_({
		"Hello, Why don't you find yourself a sample or a soundfile to play in Player B".postln;
		startButtonB.value = 0;
		Dialog.openPanel(
			okFunc:{|path|
				soundFileB = SoundFile.new;
				soundFileB.openRead(path);
				// load soud into a buffer
				bufferB = Buffer.readChannel(s, path, channels: [0]);
				// display sound on view
				soundFileViewB.soundfile_(soundFileB);
				soundFileViewB.read(0, soundFileB.numFrames);

				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpecB = ControlSpec(0, soundFileB.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewB.setSelection(0, selectionSpecB.map([0.1, 0.2]));
				// Update slider
				soundFileViewB.mouseUpAction.value(soundFileViewB);

			},
			cancelFunc: {"cancelled"}
		);
	});


	//-----------------------------------------------------------------------

	// position slider
	centerPosSliderB = RangeSlider(posSilderViewB, Rect(10, 5,sfViewWidth-20, 30 ))
	.lo_(0.1)
	.hi_(0.9)
	.action_({|sl|
		var lo, hi, size;
		lo = selectionSpecB.map(sl.lo);
		hi = selectionSpecB.map(sl.hi);
		size = hi - lo;
		soundFileViewB.setSelection(0, [lo, size]);
		if(startButtonB.value==1, {synthBStart.set(
			\centerPosLo, centerPosInSecondsB.value[0],
			\centerPosHi, centerPosInSecondsB.value[1]
		)});
	});




	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	trigSliderB = EZRanger(
		parent: subwinB,
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
			if(startButtonB.value==1,
				{synthBStart.set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
		},
		initVal: [0.1,1],
		labelWidth: 50,
		unitWidth: 30
	);
	// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

//-----------------------------------------------------------------------

	// rate slider
	rateSliderB = EZRanger(
		parent: subwinB,
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
			if(startButtonB.value ==1, {synthBStart.set(
				\rateLo, sl.lo,
				\rateHi, sl.hi)})
		},
		initVal: [0.3,1.5],
		labelWidth: 50,
		unitWidth: 30

	);
//-----------------------------------------------------------------------

	// grain duration slider
	durSliderB = EZRanger(
		parent: subwinB,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 40,
			warp: 'lin',
			step: 0.1,
			units: "sec"
		),
		action: {|sl|
			if(startButtonB.value==1, {synthBStart.set(
				\durLo, sl.lo, \durHi, sl.hi)})},
		initVal: [0.01, 0.5],
		labelWidth: 50,
		unitWidth: 30);

//-----------------------------------------------------------------------
	// pan position slider
	panSliderB = EZRanger(
		parent: subwinB,
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
			if(startButtonB.value==1, {synthBStart.set(\panLo, sl.lo, \panHi, sl.hi)})
		},
		initVal: [-0.1,0.1],
		labelWidth: 50,
		unitWidth: 30
	);


//-----------------------------------------------------------------------
	// ampslider - positioned on the master subwindow
	ampSliderB = EZRanger(
		parent: masterWin,
		bounds: Rect(50,10, 30, 300),
		label: "ch2",
		controlSpec: ControlSpec(
			minval:0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "dB"),
		action: {|sl|
			if(startButtonB.value==1, {synthBStart.set(\ampLo, sl.lo, \ampHi, sl.hi)})
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
	startButtonB = Button(subwinB, Rect(5, 90,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ==1,
			{synthBStart = Synth(\grainB,
				[

					\triggerLo, trigSliderB.lo,
					\triggerHi, trigSliderB.hi,
					\rateLo, transpToRate.value(rateSliderB.lo),
					\rateHi, transpToRate.value(rateSliderB.hi),
					\centerPosLo, centerPosInSecondsB.value[0],
					\centerPosHi, centerPosInSecondsB.value[1],
					\durLo, durSliderB.lo,
					\durHi, durSliderB.hi,
					\panLo, panSliderB.lo,
					\panHi, panSliderB.hi,
					\ampLo, ampSliderB.lo,
					\ampHi, ampSliderB.hi,
					\bufnum, bufferB,

		"Player B is playing".postln;
				]
			)},
			{
				synthBStart.set(\gate, 0);
				if(startButtonB==0,{
					synthBStart.free});
						"Player B has stopped".postln;
			}
		);

	});


	//----------------------------------------------------------------
	//---------------------- Synth B view END ----------------------------
	//----------------------------------------------------------------
      //-----------------------------------------------------------------------

	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------


	//----------------------------------------------------------------
	//---------------------- Synth C view ----------------------------
	//----------------------------------------------------------------


	// --------- SynthC  Gui window ---------------------

	subwinC = CompositeView.new(win, Rect(sfViewWidth+(20), 350, sfViewWidth/1.3, sfViewHeight+45))
	.background=Color.yellow(0.3);



	//------------------- soundFileViewC window----------------------------
	soundFileViewC = SoundFileView(win, Rect(10, 350, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
	soundFileViewC.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpecC.unmap(loFrames);
		hiSlider = selectionSpecC.unmap(hiFrames);
		2.do{centerPosSliderC.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};


	// function for the grain view to live inside a stack view

	//------------------- gui controls -------------------------
	// open buttons

	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileC = Button(subwinC, Rect(5, 50, 60, 30))
	.states_([["open file", Color.black, Color.gray]])
	.action_({
		"Hello, Why don't you find yourself a sample or a soundfile to play in Player C".postln;
		startButtonC.value = 0;
		Dialog.openPanel(
			okFunc:{|path|
				soundFileC = SoundFile.new;
				soundFileC.openRead(path);
				// load soud into a buffer
				bufferC = Buffer.readChannel(s, path, channels: [0]);
				// display sound on view
				soundFileViewC.soundfile_(soundFileC);
				soundFileViewC.read(0, soundFileC.numFrames);

				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpecC = ControlSpec(0, soundFileC.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewC.setSelection(0, selectionSpecC.map([0.1, 0.2]));
				// Update slider
				soundFileViewC.mouseUpAction.value(soundFileViewC);

			},
			cancelFunc: {"cancelled"}
		);
	});


	//-----------------------------------------------------------------------

	// position slider
	centerPosSliderC = RangeSlider(posSilderViewC, Rect(10, 5,sfViewWidth-20, 30 ))
	.lo_(0.1)
	.hi_(0.9)
	.action_({|sl|
		var lo, hi, size;
		lo = selectionSpecC.map(sl.lo);
		hi = selectionSpecC.map(sl.hi);
		size = hi - lo;
		soundFileViewC.setSelection(0, [lo, size]);
		if(startButtonC.value==1, {synthCStart.set(
			\centerPosLo, centerPosInSecondsC.value[0],
			\centerPosHi, centerPosInSecondsC.value[1]
		)});
	});




	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	trigSliderC = EZRanger(
		parent: subwinC,
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
			if(startButtonC.value==1,
				{synthCStart.set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
		},
		initVal: [0.1,1],
		labelWidth: 50,
		unitWidth: 30
	);
	// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

//-----------------------------------------------------------------------

	// rate slider
	rateSliderC = EZRanger(
		parent: subwinC,
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
			if(startButtonC.value ==1, {synthCStart.set(
				\rateLo, sl.lo,
				\rateHi, sl.hi)})
		},
		initVal: [0.3,1.5],
		labelWidth: 50,
		unitWidth: 30

	);
//-----------------------------------------------------------------------

	// grain duration slider
	durSliderC = EZRanger(
		parent: subwinC,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 40,
			warp: 'lin',
			step: 0.1,
			units: "sec"
		),
		action: {|sl|
			if(startButtonC.value==1, {synthCStart.set(
				\durLo, sl.lo, \durHi, sl.hi)})},
		initVal: [0.01, 0.5],
		labelWidth: 50,
		unitWidth: 30);

//-----------------------------------------------------------------------
	// pan position slider
	panSliderC= EZRanger(
		parent: subwinC,
		bounds: Rect(rangerXpos, 70, rangerWidth, 20),
		label: "ch3",
		controlSpec: ControlSpec(
			minval: -1,
			maxval: 1,
			warp: 'lin',
			step: 0.1,
			units: "L/R"
		),
		action: {|sl|
			if(startButtonC.value==1, {synthCStart.set(\panLo, sl.lo, \panHi, sl.hi)})
		},
		initVal: [-0.1,0.1],
		labelWidth: 50,
		unitWidth: 30
	);


//-----------------------------------------------------------------------
	// ampslider - positioned on the master subwindow
	ampSliderC = EZRanger(
		parent: masterWin,
		bounds: Rect(90,10, 30, 300),
		label: "ch3",
		controlSpec: ControlSpec(
			minval:0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "dB"),
		action: {|sl|
			if(startButtonC.value==1, {synthCStart.set(\ampLo, sl.lo, \ampHi, sl.hi)})
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
	startButtonC = Button(subwinC, Rect(5, 90,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ==1,
			{synthCStart = Synth(\grainC,
				[

					\triggerLo, trigSliderC.lo,
					\triggerHi, trigSliderC.hi,
					\rateLo, transpToRate.value(rateSliderC.lo),
					\rateHi, transpToRate.value(rateSliderC.hi),
					\centerPosLo, centerPosInSecondsC.value[0],
					\centerPosHi, centerPosInSecondsC.value[1],
					\durLo, durSliderC.lo,
					\durHi, durSliderC.hi,
					\panLo, panSliderC.lo,
					\panHi, panSliderC.hi,
					\ampLo, ampSliderC.lo,
					\ampHi, ampSliderC.hi,
					\bufnum, bufferC,

		"Player C is playing".postln;
				]
			)},
			{
				synthCStart.set(\gate, 0);
				if(startButtonC==0,{
					synthCStart.free});
						"Player C has stopped".postln;
			}
		);

	});



	//----------------------------------------------------------------
	//---------------------- Synth C view END ----------------------------
	//----------------------------------------------------------------
      //-----------------------------------------------------------------------

	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------


	//----------------------------------------------------------------
	//---------------------- Synth D view ----------------------------
	//----------------------------------------------------------------


	// --------- Synth D  Gui window ---------------------

	subwinD = CompositeView.new(win, Rect(sfViewWidth+(20), 520, sfViewWidth/1.3, sfViewHeight+45))
	.background=Color.yellow(0.3);



	//------------------- soundFileViewD window----------------------------
	soundFileViewD = SoundFileView(win, Rect(10, 520, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
	soundFileViewD.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpecD.unmap(loFrames);
		hiSlider = selectionSpecD.unmap(hiFrames);
		2.do{centerPosSliderD.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};


	// function for the grain view to live inside a stack view

	//------------------- gui controls -------------------------
	// open buttons

	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileD = Button(subwinD, Rect(5, 50, 60, 30))
	.states_([["open file", Color.black, Color.gray]])
	.action_({
		"Hello, Why don't you find yourself a sample or a soundfile to play in Player D".postln;
		startButtonD.value = 0;
		Dialog.openPanel(
			okFunc:{|path|
				soundFileD = SoundFile.new;
				soundFileD.openRead(path);
				// load soud into a buffer
				bufferD = Buffer.readChannel(s, path, channels: [0]);
				// display sound on view
				soundFileViewD.soundfile_(soundFileD);
				soundFileViewD.read(0, soundFileD.numFrames);

				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpecD = ControlSpec(0, soundFileD.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewD.setSelection(0, selectionSpecD.map([0.1, 0.2]));
				// Update slider
				soundFileViewD.mouseUpAction.value(soundFileViewD);

			},
			cancelFunc: {"cancelled"}
		);
	});


	//-----------------------------------------------------------------------

	// position slider
	centerPosSliderD = RangeSlider(posSilderViewD, Rect(10, 5,sfViewWidth-20, 30 ))
	.lo_(0.1)
	.hi_(0.9)
	.action_({|sl|
		var lo, hi, size;
		lo = selectionSpecD.map(sl.lo);
		hi = selectionSpecD.map(sl.hi);
		size = hi - lo;
		soundFileViewD.setSelection(0, [lo, size]);
		if(startButtonD.value==1, {synthDStart.set(
			\centerPosLo, centerPosInSecondsD.value[0],
			\centerPosHi, centerPosInSecondsD.value[1]
		)});
	});




	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	trigSliderD = EZRanger(
		parent: subwinD,
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
			if(startButtonD.value==1,
				{synthDStart.set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
		},
		initVal: [0.1,1],
		labelWidth: 50,
		unitWidth: 30
	);
	// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

//-----------------------------------------------------------------------

	// rate slider
	rateSliderD = EZRanger(
		parent: subwinD,
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
			if(startButtonD.value ==1, {synthDStart.set(
				\rateLo, sl.lo,
				\rateHi, sl.hi)})
		},
		initVal: [0.3,1.5],
		labelWidth: 50,
		unitWidth: 30

	);
//-----------------------------------------------------------------------

	// grain duration slider
	durSliderD = EZRanger(
		parent: subwinD,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 40,
			warp: 'lin',
			step: 0.1,
			units: "sec"
		),
		action: {|sl|
			if(startButtonD.value==1, {synthDStart.set(
				\durLo, sl.lo, \durHi, sl.hi)})},
		initVal: [0.01, 0.5],
		labelWidth: 50,
		unitWidth: 30);

//-----------------------------------------------------------------------
	// pan position slider
	panSliderD= EZRanger(
		parent: subwinD,
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
			if(startButtonD.value==1, {synthDStart.set(\panLo, sl.lo, \panHi, sl.hi)})
		},
		initVal: [-0.1,0.1],
		labelWidth: 50,
		unitWidth: 30
	);


//-----------------------------------------------------------------------
	// ampslider - positioned on the master subwindow
	ampSliderD = EZRanger(
		parent: masterWin,
		bounds: Rect(130,10, 30, 300),
		label: "ch4",
		controlSpec: ControlSpec(
			minval:0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "dB"),
		action: {|sl|
			if(busReverb==1, {busReverb.set(\amp, sl)})
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
	startButtonD = Button(subwinD, Rect(5, 90,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ==1,
			{synthDStart = Synth(\grainD,
				[

					\triggerLo, trigSliderD.lo,
					\triggerHi, trigSliderD.hi,
					\rateLo, transpToRate.value(rateSliderD.lo),
					\rateHi, transpToRate.value(rateSliderD.hi),
					\centerPosLo, centerPosInSecondsD.value[0],
					\centerPosHi, centerPosInSecondsD.value[1],
					\durLo, durSliderD.lo,
					\durHi, durSliderD.hi,
					\panLo, panSliderD.lo,
					\panHi, panSliderD.hi,
					\ampLo, ampSliderD.lo,
					\ampHi, ampSliderD.hi,
					\bufnum, bufferD,

		"Player D is playing".postln;
				]
			)},
			{
				synthDStart.set(\gate, 0);
				if(startButtonD==0,{
					synthDStart.free});
						"Player D has stopped".postln;
			}
		);

	});



	//----------------------------------------------------------------
	//---------------------- Synth E view END ----------------------------
	//----------------------------------------------------------------
      //-----------------------------------------------------------------------

	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------


	//----------------------------------------------------------------
	//---------------------- Synth E view ----------------------------
	//----------------------------------------------------------------


	// --------- Synth E  Gui window ---------------------

	subwinE = CompositeView.new(win, Rect(sfViewWidth+(20), 690, sfViewWidth/1.3, sfViewHeight+45))
	.background=Color.yellow(0.3);



	//------------------- soundFileViewD window----------------------------
	soundFileViewE = SoundFileView(win, Rect(10, 690, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
	soundFileViewE.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpecE.unmap(loFrames);
		hiSlider = selectionSpecE.unmap(hiFrames);
		2.do{centerPosSliderE.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};


	// function for the grain view to live inside a stack view

	//------------------- gui controls -------------------------
	// open buttons

	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileE = Button(subwinE, Rect(5, 50, 60, 30))
	.states_([["open file", Color.black, Color.gray]])
	.action_({
		"Hello, Why don't you find yourself a sample or a soundfile to play in Player E".postln;
		startButtonE.value = 0;
		Dialog.openPanel(
			okFunc:{|path|
				soundFileE = SoundFile.new;
				soundFileE.openRead(path);
				// load soud into a buffer
				bufferE = Buffer.readChannel(s, path, channels: [0]);
				// display sound on view
				soundFileViewE.soundfile_(soundFileE);
				soundFileViewE.read(0, soundFileE.numFrames);

				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpecE = ControlSpec(0, soundFileE.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewE.setSelection(0, selectionSpecE.map([0.1, 0.2]));
				// Update slider
				soundFileViewE.mouseUpAction.value(soundFileViewE);

			},
			cancelFunc: {"cancelled"}
		);
	});


	//-----------------------------------------------------------------------

	// position slider
	centerPosSliderE = RangeSlider(posSilderViewE, Rect(10, 5,sfViewWidth-20, 30 ))
	.lo_(0.1)
	.hi_(0.9)
	.action_({|sl|
		var lo, hi, size;
		lo = selectionSpecE.map(sl.lo);
		hi = selectionSpecE.map(sl.hi);
		size = hi - lo;
		soundFileViewE.setSelection(0, [lo, size]);
		if(startButtonE.value==1, {synthEStart.set(
			\centerPosLo, centerPosInSecondsE.value[0],
			\centerPosHi, centerPosInSecondsE.value[1]
		)});
	});




	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	trigSliderE = EZRanger(
		parent: subwinE,
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
			if(startButtonE.value==1,
				{synthEStart.set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
		},
		initVal: [0.1,1],
		labelWidth: 50,
		unitWidth: 30
	);
	// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

//-----------------------------------------------------------------------

	// rate slider
	rateSliderE = EZRanger(
		parent: subwinE,
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
			if(startButtonE.value ==1, {synthEStart.set(
				\rateLo, sl.lo,
				\rateHi, sl.hi)})
		},
		initVal: [0.3,1.5],
		labelWidth: 50,
		unitWidth: 30

	);
//-----------------------------------------------------------------------

	// grain duration slider
	durSliderE = EZRanger(
		parent: subwinE,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 40,
			warp: 'lin',
			step: 0.1,
			units: "sec"
		),
		action: {|sl|
			if(startButtonE.value==1, {synthEStart.set(
				\durLo, sl.lo, \durHi, sl.hi)})},
		initVal: [0.01, 0.5],
		labelWidth: 50,
		unitWidth: 30);

//-----------------------------------------------------------------------
	// pan position slider
	panSliderE= EZRanger(
		parent: subwinE,
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
			if(startButtonE.value==1, {synthEStart.set(\panLo, sl.lo, \panHi, sl.hi)})
		},
		initVal: [-0.1,0.1],
		labelWidth: 50,
		unitWidth: 30
	);


//-----------------------------------------------------------------------
	// ampslider - positioned on the master subwindow
	ampSliderE = EZRanger(
		parent: masterWin,
		bounds: Rect(170,10, 30, 300),
		label: "ch5",
		controlSpec: ControlSpec(
			minval:0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "dB"),
		action: {|sl|
			if(startButtonE.value==1, {synthEStart.set(\ampLo, sl.lo, \ampHi, sl.hi)})
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
	startButtonE = Button(subwinE, Rect(5, 90,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ==1,
			{synthEStart = Synth(\grainE,
				[

					\triggerLo, trigSliderE.lo,
					\triggerHi, trigSliderE.hi,
					\rateLo, transpToRate.value(rateSliderE.lo),
					\rateHi, transpToRate.value(rateSliderE.hi),
					\centerPosLo, centerPosInSecondsE.value[0],
					\centerPosHi, centerPosInSecondsE.value[1],
					\durLo, durSliderE.lo,
					\durHi, durSliderE.hi,
					\panLo, panSliderE.lo,
					\panHi, panSliderE.hi,
					\ampLo, ampSliderE.lo,
					\ampHi, ampSliderE.hi,
					\bufnum, bufferE,

		"Player E is playing".postln;
				]
			)},
			{
				synthEStart.set(\gate, 0);
				if(startButtonE==0,{
					synthEStart.free});
						"Player E has stopped".postln;
			}
		);

	});



	//----------------------------------------------------------------
	//---------------------- Synth E view END ----------------------------
	//----------------------------------------------------------------
      //-----------------------------------------------------------------------

	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------
	//----------------------------------------------------------------


	//----------------------------------------------------------------
	//---------------------- Synth F view ----------------------------
	//----------------------------------------------------------------


	// --------- Synth E  Gui window ---------------------

	subwinF = CompositeView.new(win, Rect(sfViewWidth+(20), 860, sfViewWidth/1.3, sfViewHeight+45))
	.background=Color.yellow(0.3);



	//------------------- soundFileViewD window----------------------------
	soundFileViewF = SoundFileView(win, Rect(10, 860, sfViewWidth, sfViewHeight))
	.gridOn_(true)
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(100);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
	soundFileViewF.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpecF.unmap(loFrames);
		hiSlider = selectionSpecF.unmap(hiFrames);
		2.do{centerPosSliderF.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};


	// function for the grain view to live inside a stack view

	//------------------- gui controls -------------------------
	// open buttons

	// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
	// https://sccode.org/1-4UF
	openfileF = Button(subwinF, Rect(5, 50, 60, 30))
	.states_([["open file", Color.black, Color.gray]])
	.action_({
		"Hello, Why don't you find yourself a sample or a soundfile to play in Player F".postln;
		startButtonF.value = 0;
		Dialog.openPanel(
			okFunc:{|path|
				soundFileF = SoundFile.new;
				soundFileF.openRead(path);
				// load soud into a buffer
				bufferF = Buffer.readChannel(s, path, channels: [0]);
				// display sound on view
				soundFileViewF.soundfile_(soundFileF);
				soundFileViewF.read(0, soundFileF.numFrames);

				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpecF = ControlSpec(0, soundFileF.numFrames);

				// selectionSpec.postln;
				// Set initial selection on View
				soundFileViewF.setSelection(0, selectionSpecF.map([0.1, 0.2]));
				// Update slider
				soundFileViewF.mouseUpAction.value(soundFileViewF);

			},
			cancelFunc: {"cancelled"}
		);
	});


	//-----------------------------------------------------------------------

	// position slider
	centerPosSliderF = RangeSlider(posSilderViewF, Rect(10, 5,sfViewWidth-20, 30 ))
	.lo_(0.1)
	.hi_(0.9)
	.action_({|sl|
		var lo, hi, size;
		lo = selectionSpecF.map(sl.lo);
		hi = selectionSpecF.map(sl.hi);
		size = hi - lo;
		soundFileViewF.setSelection(0, [lo, size]);
		if(startButtonF.value==1, {synthFStart.set(
			\centerPosLo, centerPosInSecondsF.value[0],
			\centerPosHi, centerPosInSecondsF.value[1]
		)});
	});




	//---------------------GRAIN CONTROLS------------------------------------
	// trigger range slider
	trigSliderF = EZRanger(
		parent: subwinF,
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
			if(startButtonF.value==1,
				{synthFStart.set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
		},
		initVal: [0.1,1],
		labelWidth: 50,
		unitWidth: 30
	);
	// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

//-----------------------------------------------------------------------

	// rate slider
	rateSliderF = EZRanger(
		parent: subwinF,
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
			if(startButtonF.value ==1, {synthFStart.set(
				\rateLo, sl.lo,
				\rateHi, sl.hi)})
		},
		initVal: [0.3,1.5],
		labelWidth: 50,
		unitWidth: 30

	);
//-----------------------------------------------------------------------

	// grain duration slider
	durSliderF = EZRanger(
		parent: subwinF,
		bounds: Rect(rangerXpos, 50, rangerWidth, 20),
		label: "grain",
		controlSpec: ControlSpec(
			minval: 0.1,
			maxval: 40,
			warp: 'lin',
			step: 0.1,
			units: "sec"
		),
		action: {|sl|
			if(startButtonF.value==1, {synthFStart.set(
				\durLo, sl.lo, \durHi, sl.hi)})},
		initVal: [0.01, 0.5],
		labelWidth: 50,
		unitWidth: 30);

//-----------------------------------------------------------------------
	// pan position slider
	panSliderF= EZRanger(
		parent: subwinF,
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
			if(startButtonF.value==1, {synthFStart.set(\panLo, sl.lo, \panHi, sl.hi)})
		},
		initVal: [-0.1,0.1],
		labelWidth: 50,
		unitWidth: 30
	);


//-----------------------------------------------------------------------
	// ampslider - positioned on the master subwindow
	ampSliderF = EZRanger(
		parent: masterWin,
		bounds: Rect(210,10, 30, 300),
		label: "ch6",
		controlSpec: ControlSpec(
			minval:0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "dB"),
		action: {|sl|
			if(startButtonF.value==1, {synthFStart.set(\ampLo, sl.lo, \ampHi, sl.hi)})
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
	startButtonF = Button(subwinF, Rect(5, 90,60, 30))
	.states_([["START",Color.black,Color.green], ["STOP", Color.black, Color.red]])
	.action_({
		arg button;
		if(button.value ==1,
			{synthFStart = Synth(\grainF,
				[

					\triggerLo, trigSliderF.lo,
					\triggerHi, trigSliderF.hi,
					\rateLo, transpToRate.value(rateSliderF.lo),
					\rateHi, transpToRate.value(rateSliderF.hi),
					\centerPosLo, centerPosInSecondsF.value[0],
					\centerPosHi, centerPosInSecondsF.value[1],
					\durLo, durSliderF.lo,
					\durHi, durSliderF.hi,
					\panLo, panSliderF.lo,
					\panHi, panSliderF.hi,
					\ampLo, ampSliderF.lo,
					\ampHi, ampSliderF.hi,
					\bufnum, bufferF,
					\out, 22,

		"Player F is playing".postln;
				]
			)},
			{
				synthEStart.set(\gate, 0);
				if(startButtonF==0,{
					synthFStart.free});
						"Player F has stopped".postln;
			}
		);

	});

















	//------------------------------------------------------------------
	//------------------------------------------------------------------
	//------------------------SynthDefs --------------------------------
	//------------------------------------------------------------------
	//------------------------------------------------------------------


	//effects here to run at the start of the program

	// reverb
	SynthDef(\busVerb, {
		arg inBus=0,outBus=0,gate=1, mix=0.5,room=0.2,damp=0.3,amp=1;

		var sig, input, env;
		env = EnvGen.kr(Env.asr(1,1,2), gate, doneAction: 2);
		input = In.ar(inBus, 2);
		sig = FreeVerb.ar(input, mix,room,damp,amp);

		Out.ar(outBus, sig*env);

	}).add;

	// delay
	SynthDef(\busDelay, {
		arg inBus=12, outBus=0, gate=1, delayTime=0.3, decayTime=10, amp;

		var sig, input, env;
		env=EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);
		input = In.ar(inBus, 2);
		sig = CombN.ar(input, 4, delayTime, decayTime, amp=1);
		Out.ar(outBus, sig*env);
	}).add;


	0.01.wait; // give it time to load the bus effects before starting them

	busReverb = Synth(\busVerb, [\inBus, 22, \outBus, 0], addAction:\addToTail);
	busDelay = Synth(\busDelay, [\inBus, 12, \outBus,0], addAction:\addToTail);





	// synth A

	SynthDef(\grainA, {
		arg out, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi;

		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;

		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		// Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

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
		// sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, grainSig*env);
	}).add;


	//-------------------------------------------------------------------------------


	// synth B

	SynthDef(\grainB, {
		arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi;

		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;

		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		// Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

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
		// sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, grainSig*env);
	}).add;


		//-------------------------------------------------------------------------------

// synth C

	SynthDef(\grainC, {
		arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi;

		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;

		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		// Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

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
		// sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, grainSig*env);
	}).add;


		//-------------------------------------------------------------------------------


	// synth D

	SynthDef(\grainD, {
		arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi;

		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;

		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		// Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

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
		// sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, grainSig*env);
	}).add;


		//-------------------------------------------------------------------------------



	// synth E

	SynthDef(\grainE, {
		arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi;

		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;

		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		// Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

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
		// sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, grainSig*env);
	}).add;


		//-------------------------------------------------------------------------------

// synth F

	SynthDef(\grainF, {
		arg out, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi;

		var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos;

		triggerAmount = LFNoise2.kr(12).range(0.5,1);
		trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
		env = EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);

		// Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

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
		// sig = Select.ar(playMode, [loopSig, grainSig]);
		Out.ar(out, grainSig*env);
	}).add;


		//-------------------------------------------------------------------------------






	//--------------- Bus effects guis


	verbAmpSlider = Slider(
		parent: masterWin,
		bounds: Rect(260,55, 30, 210),

	)
	.action_({|sl|
		busReverb.set(\amp, sl.value.linlin(0, 1, 0, 1))

	});
	StaticText(masterWin, Rect(262, 270, 30, 20))
	.string_("verb");

	delayAmpSlider = Slider(
		parent: masterWin,
		bounds: Rect(300,55, 30, 210),
	)
	.action_({|sl|
		busDelay.set(\amp, sl.value.linlin(0, 1, 0, 1))
	});
	StaticText(masterWin, Rect(297, 270, 35, 20))
	.string_("delay");




	// reverb gui view
	verbView = CompositeView(masterWin, Rect(10, 350, 200, 300))
	.background=Color.grey(0.9,0.4);



	// delay gui view
	delayView = CompositeView(masterWin, Rect(230, 350, 200, 300))
	.background=Color.grey(0.9,0.4);




	// verb gui controls


	verbMix = Knob(verbView, Rect(10, 10, 40, 40))
	.action_({|sl|});
	// verbRoom,
	// verbDamp,
	// delayTime,
	// decayTime;







	//  masterserver meter

	masterMeter = ServerMeterView(s, masterWin,0@770, 0, 23 );

	// scope

	/*scope = ScopeView(masterWin, Rect(20, 730, 180, 200))
	.bufnum=bufferA;
	scope = s;*/



})

)

