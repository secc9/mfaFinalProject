


//
// Title - Granular Workstation + GUI
// Author - Ashley Sagar
// Meanwood Audio Research And Recording
// AKA M/A/R/R/S
// date 10/05/2026

/*


******* V_2_3


// quite a lot of this code is heavily adapted from Bruno Ruviaro's Granular synthesis GUI demo
// from the SCCode website
// https://sccode.org/1-4UF


What do I want to do???

This version is the tester version for the switchable GUI




a new, multiple granular synth/ loop player/ record / oscillator


DONE
  - 6 audio slots. - done
  - make 1 granular synth first, then add in the 5 - This now (20/05/26) - DONE - 22/05/26

 - master view window
 - add in a level - Done

  - add in the volume sliders for each loop player - Done - 22/05/26
  - do I want Auxillary sends???? here????? - done 26 may -- reverb and delay
   - move  send level meters to indevidual window views - done
 - record to disk function - done
 - added in PlayBuf and gui
 - Added in Warp and gui

-  added a type button >> switches the type of file player
      - RecBuf - Image reader - oscillators -


  - add in a post window???? - done

- 2026-06-18
  - added in a switchable distort anf filter type in the image synths
  - added in a detune to Image Synths

- 2026-07-19
  - added a pluck synth

- 2026_06_23
 - added in a audio devices boot menu






 * TODO


  - add a level meter on the Subwindows/volume faders



  - maybe add in a scope

  - I have space at the bottom of each player control subwindow. maybe some effect dials>>>>????
    -  with tools to effect each slot
      -- distort
      -- fold

  -  a master effect
  -  bus effects etc
  - multiple channels out????????????? this would be nice
  - add in a recording clock

  - add filename to file view - see Ruviaro's code for GUI Demo 2


*/



(

// boot menu
var buildMarrs, audioSelectWin, devIn, devOut, ins, outs;
audioSelectWin = Window("MARRS - Audio Setup", Rect(200, 300, 380, 280))
.background_(Color.yellow(0.9, 0.4))
.front;

StaticText(audioSelectWin, Rect(10, 10, 360, 20))
.string_("Input Audio Device");
devIn = PopUpMenu(audioSelectWin, Rect(10, 32, 360, 26))
.items_(ServerOptions.inDevices);

StaticText(audioSelectWin, Rect(10, 70, 360, 20))
.string_("Output Audio Device");
devOut = PopUpMenu(audioSelectWin, Rect(10, 92, 360, 26))
.items_(ServerOptions.outDevices);




StaticText(audioSelectWin, Rect(10, 130, 120, 20))
.string_("Inputs");
ins = NumberBox(audioSelectWin, Rect(10, 152, 90, 26)).value_(2);



StaticText(audioSelectWin, Rect(140, 130, 120, 20))
.string_("Outputs");
outs = NumberBox(audioSelectWin, Rect(140, 152, 90, 26)).value_(2);


Button(audioSelectWin, Rect(10, 200, 360, 40))
.states_([["Boot with this audio device", Color.white, Color.green(0.6)]])
.action_({
	s.options.inDevice = devIn.item;
	s.options.outDevice = devOut.item;
	s.options.numInputBusChannels = ins.value.asInteger;
	s.options.numOutputBusChannels = outs.value.asInteger;
	audioSelectWin.close;
	s.reboot;
	buildMarrs.value;

});





buildMarrs = {









	s.waitForBoot({

		var win, subwinA, subwinB,subwinC,subwinD,subwinE,subwinF, masterWin, posSilderViewA,posSilderViewB,posSilderViewC,posSilderViewD,posSilderViewE,posSilderViewF;

		var  quitButton;

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

		// tgrain slider variables
		var trigSliderA, rateSliderA, durSliderA, panSliderA, ampSliderA;
		var trigSliderB, rateSliderB, durSliderB, panSliderB, ampSliderB;
		var trigSliderC, rateSliderC, durSliderC, panSliderC, ampSliderC;
		var trigSliderD, rateSliderD, durSliderD, panSliderD, ampSliderD;
		var trigSliderE, rateSliderE, durSliderE, panSliderE, ampSliderE;
		var trigSliderF, rateSliderF, durSliderF, panSliderF, ampSliderF;

		var rangerXpos = 70, rangerWidth=450;

		// playbuffer slider variables
		var playBufRateA, playBufTrigA, playBufStartPosA, playBufLoopA,playBufPanA, playbufAmpA;

		// Warp variables
		var warpScaleSizeA, warpWindowRandA, warpOverlapsA, warpPanA, warpAmpA;

		// Image variables
		var imageViewA, imageControlViewA, imageSynthViewA, imageA, imageBrightnessDataA, imageScanRoutineA, imageReadyToLoadA;
		var imageScanSpeedA, imageScanRowA = 0.5;
		var imageR_DataA, imageG_DataA, imageB_DataA;
		var imageSynthModeA, imageSynthDefsA, imageSynthTrigA;
		var sinAmpA, cutoffAmountA, qAmountA, tuneAmountA, imageFiltVolA, imageDistortMenuA, imageFilterMenuA;

		// record buffer variables
		var recViewA, recButtonA, recSynthA,inChMenuA, recStartTimeA, loadFileA;
		var jumpMenuA;




		// position slider controls
		var centerPosInSecondsA, centerPosSliderA, selectionSpecA;
		var centerPosInSecondsB, centerPosSliderB, selectionSpecB;
		var centerPosInSecondsC, centerPosSliderC, selectionSpecC;
		var centerPosInSecondsD, centerPosSliderD, selectionSpecD;
		var centerPosInSecondsE, centerPosSliderE, selectionSpecE;
		var centerPosInSecondsF, centerPosSliderF, selectionSpecF;


		//  variables for the gui switching
		var typeMenuA;
		var grainViewA, playBufViewA, warpViewA;






		var masterMeter, scope, postWindow, log;

		var reverb, delay, busReverb, busDelay, verbAmpSlider, delayAmpSlider;
		var verbView, delayView, verbTitle, delayTitle;
		var verbRoom, verbDamp, delaySend, delayTime, decayTime;
		var verbSendA,verbSendB,verbSendC,verbSendD,verbSendE,verbSendF;
		var delaySendA,delaySendB,delaySendC,delaySendD,delaySendE, delaySendF;
		var reverbSendBackgroundA,reverbSendBackgroundB,reverbSendBackgroundC,reverbSendBackgroundD,reverbSendBackgroundE,reverbSendBackgroundF;
		var delaySendBackgroundA,delaySendBackgroundB,delaySendBackgroundC,delaySendBackgroundD,delaySendBackgroundE,delaySendBackgroundF;



		var recButton, recStatusText, recSynth, recFile, recBus;


		busReverb = Bus.audio(s, 2);
		busDelay = Bus.audio(s, 2);



		// this block taken from from Bruno Ruviaro Granular synth
		// convert from centerPosSlider values (0-1)
		// to actual sound file position in seconds
		centerPosInSecondsA = {
			[
				centerPosSliderA.lo.linlin(0, 1, 0, bufferA.duration),
				centerPosSliderA.hi.linlin(0, 1, 0, bufferA.duration)
			] // returns an array [lo, hi]
		};

		centerPosInSecondsB = {
			[
				centerPosSliderB.lo.linlin(0, 1, 0, bufferB.duration),
				centerPosSliderB.hi.linlin(0, 1, 0, bufferB.duration)
			] // returns an array [lo, hi]
		};

		centerPosInSecondsC = {
			[
				centerPosSliderC.lo.linlin(0, 1, 0, bufferC.duration),
				centerPosSliderC.hi.linlin(0, 1, 0, bufferC.duration)
			] // returns an array [lo, hi]
		};

		centerPosInSecondsD = {
			[
				centerPosSliderD.lo.linlin(0, 1, 0, bufferD.duration),
				centerPosSliderD.hi.linlin(0, 1, 0, bufferD.duration)
			] // returns an array [lo, hi]
		};

		centerPosInSecondsE = {
			[
				centerPosSliderE.lo.linlin(0, 1, 0, bufferE.duration),
				centerPosSliderE.hi.linlin(0, 1, 0, bufferE.duration)
			] // returns an array [lo, hi]
		};

		centerPosInSecondsF = {
			[
				centerPosSliderF.lo.linlin(0, 1, 0, bufferF.duration),
				centerPosSliderF.hi.linlin(0, 1, 0, bufferF.duration)
			] // returns an array [lo, hi]
		};



		Buffer.freeAll; //free all buffers before loading


		// make a window
		win = Window("MARRS Workstation",
			Rect(0, 0, Window.screenBounds.width,Window.screenBounds.height);
		).front;
		win.background=Color.green(0.2);


		// post window
		postWindow = TextView(win, Rect(1270, 1010, 440, 40))
		.background_(Color.grey(0.8, 0.3))
		.editable_(false)
		.string_("---MARRS Log---")
		.stringColor_(Color.black);

		log = {|msg|
			msg.postln;
			{
				postWindow.string_(msg.asString)
			}.defer
		};

		log.("Hi. Welcome to the Meanwood Audio Workstation");










		//------------Position Slider Views ----------------------------

		posSilderViewA = CompositeView(win, Rect(10, 115, sfViewWidth, 40))
		.background = Color.yellow(0.5);
		posSilderViewA.visible_(true);
		posSilderViewB = CompositeView(win, Rect(10, 285, sfViewWidth, 40))
		.background = Color.yellow(0.5);
		posSilderViewB.visible_(true);
		posSilderViewC = CompositeView(win, Rect(10, 455, sfViewWidth, 40))
		.background = Color.yellow(0.5);
		posSilderViewC.visible_(true);
		posSilderViewD = CompositeView(win, Rect(10, 625, sfViewWidth, 40))
		.background = Color.yellow(0.5);
		posSilderViewD.visible_(true);
		posSilderViewE = CompositeView(win, Rect(10, 795, sfViewWidth, 40))
		.background = Color.yellow(0.5);
		posSilderViewE.visible_(true);
		posSilderViewF = CompositeView(win, Rect(10, 965, sfViewWidth, 40))
		.background = Color.yellow(0.5);
		posSilderViewF.visible_(true);






		// ---------- Master channel window ------------------------------

		masterWin = CompositeView(win, Rect(1270, 10, 440, 995))
		.background=Color.yellow(0.5);


		// Quit program button
		quitButton=Button(masterWin, Rect(330, 10, 100, 70))
		.states_([["QUIT ENGINE!", Color.white, Color.red]])
		.action_({
			if(imageScanRoutineA.notNil){imageScanRoutineA.stop;imageScanRoutineA=nil};
			if(masterMeter.notNil){masterMeter.remove; masterMeter=nil};
			s.quit;
			win.close;

		});


		//----------------------------------------------------------------
		//---------------------- Synth A view ----------------------------
		//----------------------------------------------------------------


		// --------- SynthA  Gui window ---------------------

		subwinA = CompositeView.new(win, Rect(sfViewWidth+(20), 10, sfViewWidth/1.3, sfViewHeight+45))
		.background=Color.yellow(0.3);



		grainViewA = CompositeView(subwinA, Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
		.background_(Color.yellow(0.7));
		grainViewA.visible_(true);

		playBufViewA = CompositeView(subwinA, Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
		.background_(Color.red(0.8, 0.6));
		playBufViewA.visible_(false);

		warpViewA = CompositeView(subwinA, Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
		.background_(Color.magenta(0.9,0.3));
		warpViewA.visible_(false);


		imageControlViewA = CompositeView(subwinA,Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
		.background_(Color.grey(0.6, 0.4));
		imageControlViewA.visible_(false);

		recViewA = CompositeView(subwinA, Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
		.background_(Color.blue(0.9, 0.4));
		recViewA.visible_(false);



		// popummenuA
		typeMenuA = PopUpMenu(subwinA, Rect(5, 10, 70, 30))
		.items_(["Grains", "Loop", "Warp", "Image", "Record"])
		.action_({
			|menu|
			switch(typeMenuA.value,
				0,{ // grain player view
					grainViewA.visible_(true);
					playBufViewA.visible_(false);
					warpViewA.visible_(false);
					imageControlViewA.visible_(false);
					soundFileViewA.visible_(true);
					centerPosSliderA.visible_(true); // show the loop slider
					posSilderViewA.visible_(true);
					imageSynthViewA.visible_(false);
					recViewA.visible_(false);


				},
				1,{ // playbuf p;ayer view
					grainViewA.visible_(false);
					playBufViewA.visible_(true);
					warpViewA.visible_(false);
					imageControlViewA.visible_(false);
					soundFileViewA.visible_(true);
					centerPosSliderA.visible_(false); // disable the loop slider
					posSilderViewA.visible_(false);
					imageSynthViewA.visible_(false);
					recViewA.visible_(false);


				},
				2,{ // warp player view
					grainViewA.visible_(false);
					playBufViewA.visible_(false);
					warpViewA.visible_(true);
					imageControlViewA.visible_(false);
					soundFileViewA.visible_(true);
					centerPosSliderA.visible_(false); // disable the loop slider
					posSilderViewA.visible_(false);
					imageSynthViewA.visible_(false);
					recViewA.visible_(false);

				},
				3,{ // Image player view
					grainViewA.visible_(false);
					playBufViewA.visible_(false);
					warpViewA.visible_(false);
					imageControlViewA.visible_(true);
					soundFileViewA.visible_(false);
					centerPosSliderA.visible_(false); // disable the loop slider
					posSilderViewA.visible_(false);
					imageSynthViewA.visible_(true);
					recViewA.visible_(false);




				},
				4,{ // record buffer viiew
					grainViewA.visible_(false);
					playBufViewA.visible_(false);
					warpViewA.visible_(false);
					imageControlViewA.visible_(false);
					soundFileViewA.visible_(false);
					centerPosSliderA.visible_(false); // disable the loop slider
					posSilderViewA.visible_(false);
					imageSynthViewA.visible_(false);
					recViewA.visible_(true);

				}
			);
			log.("Selected: " ++ menu.item);
		});

		//------------------- soundFileViewA window----------------------------
		soundFileViewA = SoundFileView(win, Rect(10, 10, sfViewWidth, sfViewHeight))
		.gridOn_(true)
		.timeCursorOn_(true)
		.timeCursorColor_(Color.white)
		.timeCursorPosition_(100);
		soundFileViewA.visible_(true);

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



		// image synth controls
		imageSynthViewA = CompositeView(win, Rect(10, 10, sfViewWidth, sfViewHeight+45))
		.background_(Color.green(0.9, 0.5));
		imageSynthViewA.visible_(false);


		//----------------------------------------------------------------

		//----------------------------------------------------------------

		// function for the grain view to live inside a stack view

		//------------------- gui controls -------------------------
		// open buttons

		// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
		// https://sccode.org/1-4UF




		imageReadyToLoadA = false;
		loadFileA = {|path, onDone|
			// audio mode
			soundFileA = SoundFile.new;
			soundFileA.openRead(path);
			bufferA = Buffer.readChannel(s, path, channels: [0], action:{{onDone.value}.defer});
			soundFileViewA.soundfile_(soundFileA);
			soundFileViewA.read(0, soundFileA.numFrames);
			selectionSpecA = ControlSpec(0, soundFileA.numFrames);
			soundFileViewA.setSelection(0, selectionSpecA.map([0.1, 0.2]));
			soundFileViewA.mouseUpAction.value(soundFileViewA);

		};
		openfileA = Button(subwinA, Rect(5, 50, 60, 30))
		.states_([["open file", Color.black, Color.gray]])
		.action_({
			var proceed = true;
			if(typeMenuA.value == 3, {
				if(imageReadyToLoadA.not, {
					log.("--- Image Mode: pick your row and synth mode first, then click Load again ---");
					imageReadyToLoadA = true;
					proceed = false;
				}, {
					imageReadyToLoadA = false;
				});
			}, {
				log.("Opening sound file for Player A");
			});
			if(proceed, {
				startButtonA.value = 0;
				Dialog.openPanel(
					{|path|
						if(typeMenuA.value == 3, {
							// image mode
							{ // defer for AppClock
								imageA = Image.open(path);
								imageBrightnessDataA = Array.fill(imageA.width, {|x|
									var col = imageA.getColor(x, imageScanRowA.linlin(0, 1, 0, imageA.height - 1).asInteger);
									(col.red + col.green + col.blue) / 3;
								});
								imageR_DataA = Array.fill(imageA.width, {|x|
									imageA.getColor(x, imageScanRowA.linlin(0, 1, 0, imageA.height - 1).asInteger).red
								});
								imageG_DataA = Array.fill(imageA.width, {|x|
									imageA.getColor(x, imageScanRowA.linlin(0, 1, 0, imageA.height - 1).asInteger).green
								});
								imageB_DataA = Array.fill(imageA.width, {|x|
									imageA.getColor(x, imageScanRowA.linlin(0, 1, 0, imageA.height - 1).asInteger).blue
								});
								imageA.free;
								log.("Image loaded - % pixels".format(imageBrightnessDataA.size));
							}.defer;
						}, {
							loadFileA.(path);
						});
					},
					{log.("cancelled")};
				);
			});
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
		})
		.visible_(true);




		//---------------------GRAIN CONTROLS------------------------------------
		// trigger range slider
		trigSliderA = EZRanger(
			parent: grainViewA,
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
			parent: grainViewA,
			bounds: Rect(rangerXpos, 30, rangerWidth, 20),
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
					\rateLo, transpToRate.value(sl.lo),
					\rateHi, transpToRate.value(sl.hi))})
			},
			initVal: [0.3,1.5],
			labelWidth: 50,
			unitWidth: 30

		);
		//-----------------------------------------------------------------------

		// grain duration slider
		durSliderA = EZRanger(
			parent: grainViewA,
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
			parent: grainViewA,
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
				if(startButtonA.value==1,{
					switch(typeMenuA.value,
						0,{synthAStart.set(\ampLo, sl.lo, \ampHi, sl.hi)},
						1,{synthAStart.set(\playBufAmp, sl.hi)},
						2,{synthAStart.set(\warpAmp, sl.hi)},
						3,{if(synthAStart.notNil,{synthAStart.set(\imageAmp, sl.hi)})};
					);
				})
			},
			initVal: [0.0,0.0],
			labelWidth: 30,
			unitWidth: 10,
			layout:'vert'
		);


		//-------------------------------------------
		//-------------------------------------------
		//-------------------------------------------
		//-------------------------------------------

		//Playbuf controls


		// trigger button
		playBufTrigA = Button(playBufViewA, Rect(rangerXpos+60, 10, rangerWidth-70, 20))
		.states_([["Trigger", Color.black, Color.gray]])
		.mouseDownAction_({|btn|
			if(synthAStart.notNil){synthAStart.set(\playBufTrig, 1)};
			{synthAStart.set(\playBufTrig, 0)}.defer(0.05);

		});


		// rate slider
		playBufRateA = Slider(playBufViewA, Rect(rangerXpos+60, 30, rangerWidth-70, 20))
		.action_({|sl|
			if(synthAStart.notNil)
			{synthAStart.set(\playBufRate, sl.value.linlin(0, 1, -1,2 ))}
		})
		.value_(2/3); // something is broken here. it plays either too fast or too slow
		StaticText(playBufViewA, Rect(rangerXpos+20, 30, 30, 20))
		.string_("rate")
		.background_(Color.green(0.6,0.6))
		.align_(\center);


		// start position
		playBufStartPosA = Slider(playBufViewA, Rect(rangerXpos+60, 50, rangerWidth-70, 20))
		.action_({|sl|
			if(synthAStart.notNil){
				synthAStart.set(\playBufStartPos, sl.value.linlin(0, 1, 0, bufferA.numFrames))
			}
		})
		.value_(0);
		StaticText(playBufViewA, Rect(rangerXpos+20, 50, 30, 20))
		.string_("start")
		.background_(Color.green(0.6,0.6))
		.align_(\center);

		// panner
		playBufPanA = Slider(playBufViewA, Rect(rangerXpos+60, 70, rangerWidth-70, 20))
		.action_({|sl|
			if(synthAStart.notNil){
				synthAStart.set(\playBufPan, sl.value.linlin(0, 1, -1, 1))}
		})
		.value_(0.5);
		StaticText(playBufViewA, Rect(rangerXpos+20, 70, 30, 20))
		.string_("pan")
		.background_(Color.green(0.6,0.6))
		.align_(\center);

		// loop on / off
		playBufLoopA = Button(playBufViewA, Rect(350, 100, 70, 40))
		.states_([["loop on", Color.black, Color.green],["Loop off",Color.black, Color.gray]])
		.action_({|btn|
			if(synthAStart.notNil,{
				if(btn.value==1,
					{synthAStart.set(\playBufLoop, 1)},
					{synthAStart.set(\playBufLoop, 0)}
				);
			});

		});



		//-------------------------------------------
		//-------------------------------------------
		//-------------------------------------------

		//Warp1 controls

		warpScaleSizeA = Slider2D(warpViewA, Rect(350,5,170,110))
		.x_(0.5)
		.y_(0.5)
		.action_({|sl|
			if(synthAStart.notNil){
				synthAStart.set(\warpFreqScale, sl.x.linlin(0,1,-10,10), \warpWinSize,sl.y.linlin(0,1,0.0001,0.1))
			}
		});
		StaticText(warpViewA, Rect(350, 115, 170, 20))
		.string_("x:freq scale / y:window size")
		.background_(Color.yellow(0.6,0.6))
		.align_(\center);

		warpOverlapsA = Slider(warpViewA, Rect(140,10,200,20))
		.action_({|sl|
			if(synthAStart.notNil){
				synthAStart.set(\warpOverlaps, sl.value.linlin(0,1,1,16))}
		})
		.value_(0.8);
		StaticText(warpViewA, Rect(85,10, 50, 15))
		.string_("overlaps")
		.background_(Color.yellow(0.6,0.6))
		.align_(\center);


		warpWindowRandA = Slider(warpViewA, Rect(140, 30, 200, 20))
		.action_({|sl|
			if(synthAStart.notNil){
				synthAStart.set(\warpWinRand, sl.value.linlin(0, 1, 0, 1))}
		});
		StaticText(warpViewA, Rect(85, 30, 50, 15))
		.string_("random")
		.background_(Color.yellow(0.6,0.6))
		.align_(\center);

		warpPanA = Slider(warpViewA, Rect(140, 50, 200, 20))
		.action_({|sl|
			if(synthAStart.notNil){
				synthAStart.set(\warpPan, sl.value.linlin(0, 1, -1,1))}
		})
		.value_(0.5);
		StaticText(warpViewA, Rect(85, 50, 50, 15))
		.string_("pan")
		.background_(Color.yellow(0.6,0.6))
		.align_(\center);


		//--------------------------------------------------------------
		// image scan A controls

		imageScanSpeedA = Slider(imageControlViewA, Rect(rangerXpos+60, 10, rangerWidth-70, 20))
		.value_(0.5);
		StaticText(imageControlViewA, Rect(rangerXpos+10, 10, 45, 20))
		.string_("speed")
		.background_(Color.grey(0.6, 0.6))
		.align_(\center);

		// row selector buttons
		Button(imageControlViewA, Rect(rangerXpos+240, 35, 50, 20))
		.states_([["Top", Color.black, Color.gray(0.6)]])
		.action_({imageScanRowA = 0.0});

		Button(imageControlViewA, Rect(rangerXpos+295, 35, 50, 20))
		.states_([["Mid", Color.black, Color.gray(0.6)]])
		.action_({imageScanRowA = 0.5});

		Button(imageControlViewA, Rect(rangerXpos+350, 35, 50, 20))
		.states_([["Bottom", Color.black,Color.gray(0.6)]])
		.action_({imageScanRowA=1.0});

		StaticText(imageControlViewA, Rect(rangerXpos+10, 35, 215, 20))
		.string_("row - choose before opening file")
		.background_(Color.grey(0.6, 0.6))
		.align_(\center);



		// synth swap
		imageSynthDefsA = [\imageSineA, \imageSineRGBA, \ksPluck, \imageSaw, \imageSquare];
		imageSynthTrigA = [false,        false,      true,    false,      false];




		// toggle between  single and three tones
		imageSynthModeA = PopUpMenu(imageControlViewA, Rect(rangerXpos+270, 60, 100, 20))
		.items_(["Sine", "SineRGB", "Pluck", "Saw", "Square"])
		.value_(0);

		StaticText(imageControlViewA, Rect(rangerXpos+10, 60, 215, 20))
		.string_("mode - choose before opening file")
		.background_(Color.grey(0.6, 0.6))
		.align_(\center);


		// image synth A Controls


		// course tuning
		tuneAmountA = Knob(imageSynthViewA, Rect(10, 10, 100, 100))
		.action_({|kn|
			if(synthAStart.notNil){
				synthAStart.set(\tune, kn.value.linlin(0, 1, -1000,1000))
			}
		})
		.value_(0.5);

		StaticText(imageSynthViewA, Rect(25, 115, 70, 20))
		.string_("tune")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 50);


		// amp into distortion
		sinAmpA = Knob(imageSynthViewA, Rect(120, 10, 100, 100))
		.action_({|kb|
			if(synthAStart.notNil){
				synthAStart.set(\sinAmp, kb.value.linlin(0,1,0,5))
			}
		})
		.value_(0.1);

		StaticText(imageSynthViewA, Rect(120, 115, 100, 20))
		.string_("dist amount")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 50);


		// filter cutoff
		cutoffAmountA = Knob(imageSynthViewA, Rect(230, 10, 100, 100))
		.action_({|kb|
			if(synthAStart.notNil){
				synthAStart.set(\cut, kb.value.linlin(0, 1, 0, 5000))
			}
		})
		.value_(1);

		StaticText(imageSynthViewA, Rect(245, 115, 70, 20))
		.string_("cutoff")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 50);


		// filter resonance
		// note: the RLPF q us backwared
		// the other 2 filters is normal,
		// not sure how to rectify this
		qAmountA = Knob(imageSynthViewA, Rect(340, 10, 100, 100))
		.action_({|kn|
			if(synthAStart.notNil){
				synthAStart.set(\q, kn.value.linlin(0, 1, 1, 0))
			}
		})
		.value_(0.5);

		StaticText(imageSynthViewA, Rect(355, 115, 70, 20))
		.string_("resonance")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 50);

		// filter volume
		imageFiltVolA =Knob(imageSynthViewA, Rect(450, 10, 100, 100))
		.action_({|kn|
			if(synthAStart.notNil){
				synthAStart.set(\filtVol, kn.value.linlin(0.001,1,0,2))
			}
		})
		.value_(0.5);
		StaticText(imageSynthViewA, Rect(455, 115, 90, 20))
		.string_("filter vol")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 50);


		// distortion type menu
		imageDistortMenuA=PopUpMenu(imageSynthViewA, Rect(600, 10, 70, 30))
		.items_(["Clean","Clip", "Fold", "Wrap"])
		.action_({|menu|
			if(synthAStart.notNil){
				synthAStart.set(\distortType, menu.value)
			}
		});

		StaticText(imageSynthViewA, Rect(570, 45, 120, 20))
		.string_("distortion type")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 30);


		// filter type menu
		imageFilterMenuA = PopUpMenu(imageSynthViewA,Rect(600, 80, 70, 20))
		.items_(["RLPF", "DFM1", "MoogVCF"])
		.action_({|menu|
			if(synthAStart.notNil){
				synthAStart.set(\filterType, menu.value)
			}
		});
		StaticText(imageSynthViewA, Rect(570, 105, 120, 20))
		.string_("filter type")
		.background_(Color.green(0.9,0.9))
		.align_(\center)
		.font_("Monaco", 30);


		//----------------------------------------------------------------------------

		// Record buffer controls

		// record button
		recButtonA = Button(recViewA, Rect(70, 50, 70, 30))
		.states_([["● Rec", Color.white, Color.red], ["■ Stop", Color.black, Color.gray]])
		.action_({|btn|
			if(btn.value==1){
				recStartTimeA = Main.elapsedTime;
				bufferA = Buffer.alloc(s, s.sampleRate*30, 1); // 30 sec mono buffer
				recSynthA = Synth(\recBufA, [\bufnum, bufferA, \inCh, inChMenuA.value]);
			}{
				var recFrames = ((Main.elapsedTime - recStartTimeA)*s.sampleRate).asInteger.min(bufferA.numFrames);

				var path = Platform.defaultTempDir +/+ "marrsRecA.wav";
				var oldBuf = bufferA;
				recSynthA.free;
				log.("recorded " ++ (Main.elapsedTime - recStartTimeA).round(0.01) ++ "s");
				{
					oldBuf.write(path, "wav", "int16", recFrames);
					s.sync;
					oldBuf.free;
					{loadFileA.(path, {
						typeMenuA.valueAction_(jumpMenuA.value);
						startButtonA.valueAction_(1);
					});
					}.defer;
				}.fork;
			};
		});


		inChMenuA = PopUpMenu(recViewA, Rect(80, 10, 70, 30))
		.items_((1..s.options.numInputBusChannels).collect({|i| "In " ++ i}));

		StaticText(recViewA, Rect(10, 10, 55, 26))
		.string_("input")
		.align_(\right);


		jumpMenuA = PopUpMenu(recViewA, Rect(250, 10, 90, 26))
		.items_(["Grains", "Loop", "Warp"]);
		StaticText(recViewA, Rect(155, 10, 90, 30))
		.string_("Send recording to ->")
		.background_(Color.yellow(0.8, 0.6));





		//----------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		//----------------------------------------------------------------------------



		//reverb send knob
		reverbSendBackgroundA=CompositeView(subwinA, Rect(120, 100, 100, 40))
		.background_(Color.cyan(0.4));

		verbSendA = Knob(reverbSendBackgroundA,Rect(5, 5, 30, 30))
		.action_({|kn|
			synthAStart.set(\verbSend, kn.value.linlin(0, 1, 0, 1))
		});
		StaticText(reverbSendBackgroundA, Rect(30, 5, 70, 30))
		.string_("reverb send")
		.align_(\center);


		//delay send knob
		delaySendBackgroundA =CompositeView(subwinA, Rect(230, 100, 100, 40))
		.background_(Color.cyan(0.4));


		delaySendA = Knob(delaySendBackgroundA,Rect(5, 5, 30, 30))
		.action_({|kn|
			synthAStart.set(\delaySend, kn.value.linlin(0, 1, 0, 1))
		});
		StaticText(delaySendBackgroundA, Rect(35, 5, 60, 30))
		.string_("delay send")
		.align_(\center);



		//-----------------------------------------------------------------------
		// start button
		// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
		// https://sccode.org/1-4UF


		startButtonA = Button(subwinA, Rect(5, 90, 60, 30))
		.states_([["START", Color.black, Color.green], ["STOP", Color.black, Color.red]])
		.action_({
			arg button;
			// Is the button being pressed (1) or released/stopped (0)?
			if(button.value == 1,
				// --- PRESSED ---
				{
					// A file IS loaded — now check which synth type is selected
					switch(typeMenuA.value,
						// Menu is on Grains (index 0) — fire TGrains
						0,{
							// First, check if a file has been loaded into the buffer.
							// bufferA.isNil means "bufferA has nothing in it yet"
							if(bufferA.isNil,
								// No file loaded — warn the user and reset the button
								{
									log.("Please load a file first!");
									button.value_(0); // un-press the button visually
								},{
									synthAStart = Synth(\tgrainsPlayerA, [
										\triggerLo,   trigSliderA.lo,
										\triggerHi,   trigSliderA.hi,
										\rateLo,      transpToRate.value(rateSliderA.lo),
										\rateHi,      transpToRate.value(rateSliderA.hi),
										\centerPosLo, centerPosInSecondsA.value[0],
										\centerPosHi, centerPosInSecondsA.value[1],
										\durLo,       durSliderA.lo,
										\durHi,       durSliderA.hi,
										\panLo,       panSliderA.lo,
										\panHi,       panSliderA.hi,
										\ampLo,       ampSliderA.lo,
										\ampHi,       ampSliderA.hi,
										\bufnum,      bufferA,
										\verbSend,    verbSendA.value,
										\delaySend,   delaySendA.value,
									]);
									log.("TGrains playing");
							});
						},


						// Menu is on Loop (index 1) — fire PlayBuf
						1,{
							if(bufferA.isNil,
								{ log.("Please load a file first");
									button.value_(0);
								},{
									synthAStart = Synth(\playBufferA, [
										\bufnum,     bufferA,
										\playBufRate,playBufRateA.value.linlin(0,1,-1,2),
										\playBufAmp, ampSliderA.lo,
										\playBufPan, playBufPanA.value.linlin(0,1,-1,1),
										\playBufStartPos, 0.0,
										\playBufTrig, 0,
										\playBufLoop, 1,
										\verbSend,  verbSendA.value,
										\delaySend, delaySendA.value,
									]);
									log.("PlayBuf playing");
							});
						},


						2,{// menu is on warp (index 2)
							if(bufferA.isNil,
								{ log.("Please load a file first");
									button.value_(0);
								},{

									synthAStart = Synth(\warpBufferA,[
										\bufnum, bufferA,
										// \warpPointer,
										\warpFreqScale,warpScaleSizeA.x.linlin(0,1,-10,10),
										\warpWinSize, warpScaleSizeA.y.linlin(0, 1, 0.01,4),
										\warpPan, warpPanA.value.linlin(0,1,-1,1),
										\warpOverlaps, warpOverlapsA.value.linlin(0,1,1,16),
										\warpWinRand,warpWindowRandA.value,
										\warpAmp, ampSliderA.lo,
										\verbSend, verbSendA.value,
										\delaySend, delaySendA.value

									]);
									log.("Warp buffer Playing");
							});
						},


						3,{
							// menu is on image (index 3)
							if(imageBrightnessDataA.isNil, {
								log.("Load an image first");
								button.value_(0);
							},{
								var amp = ampSliderA.hi;
								var verbSend = verbSendA.value;
								var delaySend = delaySendA.value;
								var mode = imageSynthModeA.value;
								var tune = tuneAmountA.value.linlin(0, 1, -1000,1000);
								var sinAmp = sinAmpA.value.linlin(0, 1, 0, 5);
								var cut = cutoffAmountA.value.linlin(0, 1, 0, 5000);
								var q = qAmountA.value.linlin(0, 1, 1, 0);
								var filtVol = imageFiltVolA.value.linlin(0.001, 1, 0, 2);
								var distortType = imageDistortMenuA.value;
								var filterType = imageFilterMenuA.value;

								imageScanRoutineA = Routine({
									imageBrightnessDataA.size.do({|i|
										var freq = imageBrightnessDataA[i].max(0.001).linexp(0.001,1,80,4000);
										var freqR = imageR_DataA[i].max(0.001).linexp(0.001,1,80, 4000);
										var freqG = imageG_DataA[i].max(0.001).linexp(0.001,1,80, 4000);
										var freqB = imageB_DataA[i].max(0.001).linexp(0.001,1,80, 4000);
										var speed = imageScanSpeedA.value.linlin(0, 1, 0.5, 0.01);

										{
											var args = [
												\freq, freq,
												\freqR, freqR,
												\freqG, freqG,
												\freqB, freqB,
												\imageAmp, ampSliderA.hi,
												\tune, tuneAmountA.value.linlin(0, 1, -1000,1000),
												\sinAmp, sinAmpA.value.linlin(0, 1, 0, 5),
												\cut, cutoffAmountA.value.linlin(0, 1, 0, 5000),
												\q, qAmountA.value.linlin(0, 1, 1, 0),
												\filtVol, imageFiltVolA.value.linlin(0.001, 1, 0, 2),
												\distortType, imageDistortMenuA.value,
												\filterType, imageFilterMenuA.value,
												\verbSend, verbSendA.value,
												\delaySend, delaySendA.value
											];
											if(imageSynthTrigA[mode],{
												//triggered: a fresh synth every pixel (frees itself)
												Synth(imageSynthDefsA[mode], args);
											},{
												// held: make one, then slide its pitch
												if(synthAStart.isNil,{
													synthAStart = Synth(imageSynthDefsA[mode], args);
												},{
													synthAStart.set(\freq, freq, \freqR, freqR, \freqG, freqG, \freqB, freqB);

												});
											});
										}.defer;
										speed.wait;
									});
									log.("Scan Complete");
								}).play(AppClock);
								// should end here???
							});
						};
					);
				},
				// --- RELEASED / STOPPED ---
				{
					if(imageScanRoutineA.notNil,{
						imageScanRoutineA.stop;
						imageScanRoutineA = nil;
					});
					if(synthAStart.notNil, {
						synthAStart.set(\gate, 0);
						synthAStart = nil;
						log.("Player A has stopped");
					}, {
						log.("Nothing was playing");
					});
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











		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------SynthDefs --------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------






		// Slot A
		// TGrains Player
		SynthDef(\tgrainsPlayerA, {
			arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi, verbSend=0, delaySend=0;

			var env,sig, grainSig,loopSig, trig, triggerAmount, rate, dur, pan, amp, centerPos, wetVerb, wetDelay;

			triggerAmount = LFNoise2.kr(12).range(0.5,1);
			trig = Impulse.kr(LFNoise0.kr(triggerAmount).range(triggerLo, triggerHi));
			env = EnvGen.kr(Env.asr(1,1,1), gate, doneAction: 2);

			# rate, centerPos, dur, pan, amp = Demand.kr(
				trig,
				0,
				[
					Dwhite(rateLo, rateHi),
					Dwhite(centerPosLo, centerPosHi),
					Dwhite(durLo, durHi),
					Dwhite(panLo, panHi),
					Dwhite(ampLo, ampHi)
				]
			);

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
			grainSig = grainSig * env;
			Out.ar(out, grainSig);
			wetVerb = grainSig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = grainSig * delaySend;
			Out.ar(busDelay, wetDelay);
		}).add;


		//-------------------------------------------------------------------------------

		// Slot A Playbuf
		SynthDef(\playBufferA, {
			arg out=0, gate=1,bufnum,playBufRate=1,playBufAmp=1,playBufPan=0, verbSend=0, delaySend=0, playBufStartPos=0.0,playBufTrig=0, playBufLoop=1;
			var sig, env,wetVerb, wetDelay;
			env = EnvGen.kr(Env.asr(0.1,1,1),gate: gate,doneAction: 2);
			sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*playBufRate,trigger: playBufTrig,startPos: playBufStartPos, loop:playBufLoop);
			sig = Pan2.ar(sig, playBufPan, playBufAmp)*env;
			Out.ar(out, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;


		//-------------------------------------------------------------------------

		// Slot A Warp

		SynthDef(\warpBufferA, {
			arg out = 0, gate=1, bufnum,warpFreqScale=0.1,warpWinSize=0.2,warpPan=0.0,warpWinRand=0.1,warpOverlaps=8, warpAmp=0.3, verbSend=0, delaySend=0;
			var sig, env, wetVerb, wetDelay,warpPointer;
			warpPointer = LFSaw.ar(1/15).range(0,1);
			env = EnvGen.kr(Env.asr(1,1,1),gate, doneAction: 2);
			sig = Warp1.ar(1,bufnum,warpPointer,warpFreqScale,warpWinSize,-1,warpOverlaps,warpWinRand,2,0.1)*env;
			sig = Pan2.ar(sig, warpPan, warpAmp);
			Out.ar(out, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		//--------------------------------------------------

		// image Synth A

		SynthDef(\imageSineA, {
			arg out=0, freq = 440, tune=0,sinAmp=0.3, cut=5000,q=1, filtVol=1,imageAmp=0.3, distortType=0, filterType=0, imagePan=0.0, gate=1, verbSend=0,delaySend=0;
			var sig, env, wetVerb, wetDelay;
			env = EnvGen.kr(Env.asr(1,1,1),gate, doneAction: 2);
			sig = SinOsc.ar(freq+tune,0,  sinAmp);

			// distort select
			sig = Select.ar(distortType,[
				sig,
				Clip.ar(sig, 0, 1),
				Fold.ar(sig,0,1),
				Wrap.ar(sig, 0, 1)
			]);
			// filter select
			sig = Select.ar(filterType,[
				RLPF.ar(sig, cut, q,filtVol),
				DFM1.ar(sig, cut, q, filtVol),
				MoogVCF.ar(sig, cut, q, filtVol)

			]);
			sig = Pan2.ar(sig, imagePan, imageAmp )*env;
			Out.ar(out, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;


		// image RGB Sine

		SynthDef(\imageSineRGBA, {
			arg out=0, freqR=220, freqG=330, freqB=440,tune=0,sinAmp=0.3, distortType=0,filterType=0, filtVol=1,cut=5000,q=1, imageAmp=0.3,gate=1,verbSend=0,delaySend=0;
			var  sig, env, wetVerb, wetDelay;
			env = EnvGen.kr(Env.asr(1,1,1),gate,doneAction:2);
			sig = Pan2.ar(SinOsc.ar([freqR,freqG,freqB]+tune, 0, sinAmp), [-0.8, 0.0, 0.8]);
			// distort type
			sig = Select.ar(distortType,[
				sig,
				Clip.ar(sig, 0, 1),
				Fold.ar(sig,0,1),
				Wrap.ar(sig, 0, 1)
			]);

			// filter select
			sig = Select.ar(filterType,[
				RLPF.ar(sig, cut, q,filtVol),
				DFM1.ar(sig, cut, q, filtVol),
				MoogVCF.ar(sig, cut, q, filtVol)

			]);
			sig = sig.sum *(1/3) * imageAmp * env;
			Out.ar(out, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);
		}).add;

		// image KS_Pluck from ixi tutorial 10
		SynthDef(\ksPluck,{ arg out=0, freq=220, imagePan=0, rand=0.3, delayTime=3, noiseType=1, verbSend=0, delaySend=0, distortType=0, filterType=0, filtVol=1, cut=5000, q=1, sinAmp=0.3, tune=0, imageAmp=0.3;
			var sig, env, wetVerb, wetDelay;
			env = Env.new(#[1, 1, 0],#[2, 0.001]);
			// A simple exciter x, with some randomness.
			sig = Decay.ar(Impulse.ar(0, 0, rand), 0.1+rand, WhiteNoise.ar(sinAmp));
			sig = CombL.ar(sig, 0.05, (freq+tune).max(20).reciprocal, delayTime, EnvGen.ar(env, doneAction:2));

			// distort select
			sig = Select.ar(distortType, [
				sig,
				Clip.ar(sig, 0, 1),
				Fold.ar(sig,0,1),
				Wrap.ar(sig, 0, 1)
			]);

			// filter selct
			sig = Select.ar(filterType,[
				RLPF.ar(sig, cut, q,filtVol),
				DFM1.ar(sig, cut, q, filtVol),
				MoogVCF.ar(sig, cut, q, filtVol)

			]);

			sig = Pan2.ar(sig, imagePan, imageAmp);
			Out.ar(out, LeakDC.ar(sig));
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);
		}).add;


/*	// image fm
	SynthDef(\imageFM, {
		arg out=0, freq=220, imagePan=0, verbSend=0, delaySend=0, distortType=o, filterType=0, filtVol=1,
		cut=5000, q=1,sinAmp=0.3,tune=0, imageAmp=0.3, gate=1;
		var env, carrier, modulator, wetVerb, wetDelay;
		env = EnvGen.kr(Env.asr(1,1,1),gate, doneAction: 2);
		modulator = SinOsc.ar(400, 0, 0.1);
		carrier = SinOsc.ar(freq, 0, 0.1);
	})*/


		SynthDef(\imageSaw, {
			arg out=0, freqR=220, freqG=330, freqB=440, tune = 0, sinAmp=0.3, cut=5000, q=1, filtVol=1, imageAmp=0.3,imagePan=0, distortType=0, filterType=0, gate=1, verbSend=0, delaySend=0;
			var sig, env, wetDelay, wetVerb;
			env = EnvGen.kr(Env.asr(1, 1, 1),gate, doneAction: 2);
			sig = Pan2.ar(Saw.ar([freqR,freqG,freqB]+tune, sinAmp), [-0.8, 0.0, 0.8]);
			// distort select
			sig = Select.ar(distortType,[
				sig,
				Clip.ar(sig, 0, 1),
				Fold.ar(sig,0,1),
				Wrap.ar(sig, 0, 1)
			]);
			// filter select
			sig = Select.ar(filterType,[
				RLPF.ar(sig, cut, q,filtVol),
				DFM1.ar(sig, cut, q, filtVol),
				MoogVCF.ar(sig, cut, q, filtVol)

			]);
			sig = sig.sum *(1/3) * imageAmp * env;
			Out.ar(out, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		SynthDef(\imageSquare, {
			arg out=0, freqR=220, freqG=330, freqB=440, tune = 0, sinAmp=0.3, cut=5000, q=1, filtVol=1, imageAmp=0.3,imagePan=0, distortType=0, filterType=0, gate=1, verbSend=0, delaySend=0;
			var sig, env, wetDelay, wetVerb;
			env = EnvGen.kr(Env.asr(1, 1, 1),gate, doneAction: 2);
			sig = Pan2.ar(Pulse.ar([freqR,freqG,freqB]+tune, 0.5, sinAmp),[-0.8, 0.0, 0.8]);
			// distort select
			sig = Select.ar(distortType,[
				sig,
				Clip.ar(sig, 0, 1),
				Fold.ar(sig,0,1),
				Wrap.ar(sig, 0, 1)
			]);
			// filter select
			sig = Select.ar(filterType,[
				RLPF.ar(sig, cut, q,filtVol),
				DFM1.ar(sig, cut, q, filtVol),
				MoogVCF.ar(sig, cut, q, filtVol)

			]);

			sig = sig.sum *(1/3) * imageAmp * env;

			Out.ar(out, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		//-------------------------------------------------------------------------

		// recording buffer



		SynthDef(\recBufA, {
			arg bufnum, inCh = 0;
			var in = SoundIn.ar(inCh);
			RecordBuf.ar(in, bufnum, loop: 0, doneAction:2);
		}).add;

		//-------------------------------------------------------------------------


		//effects here to run at the start of the program

		// reverb
		SynthDef(\busVerb, {
			arg inBus=0,outBus=0,gate=1, mix=1,room=0.5,damp=0.5,amp=0.6;

			var sig, input, env;
			// env = EnvGen.kr(Env.asr(1,1,2), gate, doneAction: 2);
			input = In.ar(inBus, 2);
			sig = FreeVerb.ar(input, mix,room,damp,amp);

			Out.ar(outBus, sig);

		}).add;

		// delay
		SynthDef(\busDelay, {
			arg inBus=24, outBus=0, gate=1, delayTime=0.3, decayTime=10, amp=0.6;

			var sig, input, env;
			// env=EnvGen.kr(Env.asr(1,1,4), gate, doneAction: 2);
			input = In.ar(inBus, 2);
			sig = CombN.ar(input, 2, delayTime, decayTime, amp);
			Out.ar(outBus, sig);
		}).add;


		0.01.wait; // give it time to load the bus effects before starting them

		reverb = Synth(\busVerb, [\inBus, busReverb.index, \outBus, 0, \amp, 0.6,\room, 0.5,\damp,0.5], addAction:\addToTail);
		delay = Synth(\busDelay, [\inBus, busDelay.index, \outBus,0, \amp, 0.6, \delayTime, 0.3], addAction:\addToTail);






		//--------------- Bus effects guis

		// reverb gui view
		verbView = CompositeView(masterWin, Rect(10, 350, 170, 300))
		.background=Color.grey(0.9,0.4);



		// delay gui view
		delayView = CompositeView(masterWin, Rect(190, 350, 170, 300))
		.background=Color.grey(0.9,0.4);




		// verb gui controls




		StaticText(verbView, Rect(10, 10, 150, 40))
		.string_("Reverb")
		.background_(Color.blue(0.6, 0.6))
		.align_(\center)
		.font_(Font("Arial", 28,true ));

		verbRoom = Slider(verbView, Rect(13, 60, 40, 200))
		.action_({|sl|
			reverb.set(\room, sl.value.linlin(0, 1, 0, 1))
		})
		.value_(0.5)
		.orientation_(\vert);
		StaticText(verbView, Rect(16,260, 35, 30))
		.string_("room size")
		.align_(\center);



		verbDamp= Slider(verbView, Rect(63, 60, 40, 200))
		.action_({|sl|
			reverb.set(\damp, sl.value.linlin(0, 1, 0, 1))
		})
		.value_(0.5)
		.orientation_(\vert);
		StaticText(verbView, Rect(66, 260, 35, 30))
		.string_("damp size")
		.align_(\center);


		// amp
		verbAmpSlider = Slider(
			parent: verbView,
			bounds: Rect(113,60, 40, 200),
		)
		.action_({|sl|
			reverb.set(\amp, sl.value.linlin(0, 1, 0, 1))

		})
		.value_(0.6);
		StaticText(verbView, Rect(116, 260, 30, 20))
		.string_("amp");



		// delay gui controls

		StaticText(delayView, Rect(10, 10, 150, 40))
		.string_("Delay")
		.background_(Color.blue(0.6, 0.6))
		.align_(\center)
		.font_(Font("Arial", 28,true));


		delayTime = Slider(delayView, Rect(13, 60, 40, 200))
		.action_({|sl|
			delay.set(\delayTime, sl.value.linlin(0, 1, 0, 1))
		})
		.value_(0.5)
		.orientation_(\vert);
		StaticText(delayView, Rect(16, 260, 35, 30))
		.string_("delay time")
		.align_(\center);


		decayTime = Slider(delayView, Rect(63, 60, 40, 200))
		.action_({|sl|
			delay.set(\decayTime, sl.value.linlin(0, 1, 0, 50))
		})
		.value_(0.5)
		.orientation_(\vert);
		StaticText(delayView, Rect(66, 260, 35, 30))
		.string_("decay time")
		.align_(\center);

		delayAmpSlider = Slider(
			parent: delayView,
			bounds: Rect(113, 60, 40, 200),
		)
		.action_({|sl|
			delay.set(\amp, sl.value.linlin(0, 1, 0, 1))
		})
		.value_(0.6);
		StaticText(delayView, Rect(116, 260, 35, 20))
		.string_("amp");




		// from Claude

		// ---------- WORKING RECORD BUTTON ----------

		recButton = Button(masterWin, Rect(10, 700, 50, 50))
		.states_([["REC", Color.black, Color.red],["STOP", Color.black, Color.grey]])
		.action_({|btn|
			if(btn.value==1){
				Dialog.savePanel({|path|
					if(path.extension !="wav"){path = path ++ ".wav"};

					s.recorder.recHeaderFormat = "wav";
					s.recorder.recSampleFormat = "float";

					s.record(path:path, numChannels:2, bus: 0);

					recStatusText.string = "Recording: " ++ path.basename;
					recStatusText.background = Color.red(0.7);
				})
			} {
				s.stopRecording;
				recStatusText.string = "Ready";
				recStatusText.background = Color.green(0.7);
			}
		});

		recStatusText = StaticText(masterWin, Rect(0, 670, 150, 30))
		.string_("Ready")
		.background_(Color.green(0.7))
		.align_(\center);

		// Cleanup when window closes



		//  masterserver meter

		masterMeter = ServerMeterView(s, masterWin,0@770, s.options.numInputBusChannels, s.options.numOutputBusChannels);


		// scope - for another time

	/*scope = ScopeView(masterWin, Rect(240,800, 180, 180));
	scope.bufnum = [bufferA, bufferB, bufferC, bufferD,bufferE,bufferF];
	scope.server = s;

	// code from example files ScopeView
	SynthDef(\monoScope, {|bus, bufnum|
		var z;
		z = In.ar(bus, 2);

		ScopeOut2.ar(z, bufnum);
		Out.ar(0, z)
	}).play(
		target: RootNode(s),
		args: [\bus, b.index, \bufnum,scope.bufnum ],addAction: \addToTail
	);
	*/





		win.onClose = {
			if(imageScanRoutineA.notNil,{imageScanRoutineA.stop; imageScanRoutineA=nil;});
			if(masterMeter.notNil){masterMeter.remove;masterMeter = nil};// kills server meter

			if(recSynth.notNil) { recSynth.free };
			if(recBus.notNil) { recBus.free };
			if(recFile.notNil) { recFile.close; recFile = nil };
			log.("Thanks for your time. Goodbye");

			SystemClock.sched(0.1, { s.freeAll; nil});
		};

	})
}
)


