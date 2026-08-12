


//
// Title - Granular Workstation + GUI
// Author - Ashley Sagar
// Meanwood Audio Research And Recording
// AKA M/A/R/R/S
// date 10/05/2026

/*


******* V_2_5_1
- Upscaling the workstation to 6 slots


//--------------------------------------------
// To run this software you will need the SuperCollider application installed on your computer
// https://supercollider.github.io/
// make sure that if you want to use this version you must have
// sc-3 plugins installed
// https://supercollider.github.io/sc3-plugins/

// unzip and add into Extensions dir
// recompile class library -> shift + cmd + L
// and re - run software


// The TGRAIN code is heavily adapted from Bruno Ruviaro's Granular synthesis GUI demo
// from the SCCode website
// https://sccode.org/1-4UF


// This workstation has only been tested on the Apple OSX operating system
//
//--------------------------------------------


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

- 2026-06-19
  - added a pluck synth

- 2026_06_23
 - added in a audio devices boot menu
 - added in a record mode
 - added a record switching synth that jumps to a different loop player

- 2026_06_24
 - added in a level meter
 - tinkkered a little with the Warp 1 player settings
  - add a level meter on the Subwindows/volume faders - done
- 2026_06_24
 - added in a Sample and Hold Synth


- 2026_07_02  ALL DONE
 latch controls still to do
  - pulse width needs moving
  - Blip harmonics needs moving
  - FOrmant controls need moving
  - PMOSc controls need moving
  - SineFM feedback also needs moving



- added in a gain dail for the record synth

- 2026_07_27
   - added a lag time on the image synths
  - added a rhythm wobble on image sequencer
-
-

 * TODO






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

  - convert lots of label arguments to variables

  - add a lag to the image synt and slow even further
*/



(
// TO RUN MARRS WORKSTATION
// place cursor here and run code with cmd + return.

// boot menu
var buildMarrs, audioSelectWin, devIn, devOut, ins, outs, srMenu;
audioSelectWin = Window("MARRS - Audio Setup", Rect(200, 300, 380, 280))
.background_(Color.yellow(0.9, 0.4))
.front;


devIn = PopUpMenu(audioSelectWin, Rect(10, 30, 360, 26))
.items_(ServerOptions.inDevices);
StaticText(audioSelectWin, Rect(10, 10, 360, 20))
.string_("Input Audio Device");


devOut = PopUpMenu(audioSelectWin, Rect(10, 82, 360, 26))
.items_(ServerOptions.outDevices);
StaticText(audioSelectWin, Rect(10, 60, 360, 20))
.string_("Output Audio Device");


// srMenu = PopUpMenu(audioSelectWin, Rect(10, 130, 360,26))
// .items_(["Default", "44100", "48000"]);
// StaticText(audioSelectWin, Rect(10, 110, 360, 20))
// .string_("Sample Rate");


ins = NumberBox(audioSelectWin, Rect(50, 170, 90, 26)).value_(2);
StaticText(audioSelectWin, Rect(10, 180, 50, 20))
.string_("Inputs");


outs = NumberBox(audioSelectWin, Rect(240, 170, 90, 26)).value_(2);
StaticText(audioSelectWin, Rect(190, 180, 50, 20))
.string_("Outputs");


Button(audioSelectWin, Rect(10, 230, 360, 40))
.states_([["Boot with this audio device", Color.white, Color.green(0.6)]])
.action_({
	s.options.inDevice = devIn.item;
	s.options.outDevice = devOut.item;
	s.options.numInputBusChannels = ins.value.asInteger;
	s.options.numOutputBusChannels = outs.value.asInteger;

	// sample rate
/*	if(srMenu.value == 0, {s.options.sampleRate = nil}, // "default" -> let device decide
		{s.options.sampleRate = srMenu.item.asInteger} // e.g "48000" -> 48000

	);*/

	audioSelectWin.close;
	s.reboot;
	buildMarrs.value;

});





buildMarrs = {









	s.doWhenBooted({



		var win, subwins, masterWin, posSliderViews;
		var quitButton;
		var soundFileViews;
		var sfViewWidth = 700, sfViewHeight=100, sfvYPos=40;
		var openFiles;
		var startButtons;
		var soundFiles;
		var buffers;
		var synthsStart;

		var grainViews, playBufViews, warpViews, imageControlViews, recViews, latchViews, latchSynthViews, imageSynthViews;


		var ampSliders;

		var verbSends, delaySends, reverbSendBackgrounds, delaySendBackgrounds;


		var tuneAmounts, sinAmps, cutoffAmounts, qAmounts, imageFiltVols, imageDistortMenus, imageFilterMenus;


		var monBusses;

		// image data
		var images, imageBrightnessDatas, imageScanRoutines, imageReadyToLoads;
		var imageScanSpeeds, imageScanRows;
		var imageR_Datas, imageG_Datas, imageB_Datas;
		var imageSynthModes;

		var imageSynthDefs, imageSynthTrig;
		var imageLagTimes, imageScanWobble;


		var latchPulseWidths, latchNHarms, latchOscMenus, latchPWLabels, latchNHarmLabels, latchFormFreqs, latchBwFreqs, latchFormFreqLabels, latchBwFreqLabels, latchCoarseA;

		var latchPmRatios, latchPmIndexs, latchPmRatioLabels, latchPmIndexLabels, latchFbs, latchFbLabels, latchDetunes, latchDistortMenus, latchDistAmps;


		var latchTrigSpeeds, latchFreqAAs, latchFreqBAs, latchSpeeds, latchSpeedLabels;

		var latchPatMenus, latchTrigMenus;
		var latchFilterMenus, latchCuts, latchQs;






		// old variables below
		// converts rate value -- taken from Bruno Ruviaro Granular synth
		var transpToRate = {arg transp; transp.linexp(-24,24,0.25, 4)};

		// tgrain slider variables
		var trigSliders, rateSliders, durSliders, panSliders;


		var rangerXpos = 70, rangerWidth=450;

		// playbuffer slider variables
		var playBufRates, playBufTrigs, playBufStartPoses, playBufLoops,playBufPans;

		// Warp variables
		var warpScaleSizes, warpWindowRands, warpOverlaps, warpPans;







		// record buffer variables
		var recButtons, recSynths, inChMenus, recStartTimes, loadFileA, inputGains;

		var jumpMenus, meters, meterSynths;



		//------------- sequencing

		// latch
		var latchSynthViewA;





		// output routing
		var outSels, outLevelMeters, outLevelMons;



		// position slider controls
		var centerPosInSecondsA, centerPosSliders, selectionSpecs;
		var centerPosInSecondsB;
		var centerPosInSecondsC;
		var centerPosInSecondsD;
		var centerPosInSecondsE;
		var centerPosInSecondsF;


		//  variables for the gui switching
		var typeMenus;









		var masterMeter, scope, postWindow, log;

		var reverb, delay, busReverb, busDelay, verbAmpSlider, delayAmpSlider;
		var verbView, delayView, delayTitle;
		var verbRoom, verbDamp, delaySend, delayTime, decayTime;


		var recButton, recStatusText, recSynth, recFile, recBus;


		busReverb = Bus.audio(s, 2);
		busDelay = Bus.audio(s, 2);



		// this block taken from from Bruno Ruviaro Granular synth
		// convert from centerPosSlider values (0-1)
		// to actual sound file position in seconds
		centerPosInSecondsA = {|chanIdx|
			[
				centerPosSliders[chanIdx].lo.linlin(0, 1, 0, buffers[chanIdx].duration),
				centerPosSliders[chanIdx].hi.linlin(0, 1, 0, buffers[chanIdx].duration)
			] // returns an array [lo, hi]
		};




		Buffer.freeAll; //free all buffers before loading


		// make a window
		win = Window("MARRS Workstation",
			Rect(0, 0, Window.screenBounds.width,Window.screenBounds.height);
		).front;
		win.background=Color.green(0.2);



		buffers = Array.newClear(6);
		soundFileViews = Array.newClear(6);
		subwins = Array.newClear(6);
		soundFiles = Array.newClear(6);
		openFiles = Array.newClear(6);
		startButtons = Array.newClear(6);
		synthsStart = Array.newClear(6);
		posSliderViews = Array.newClear(6);
		typeMenus = Array.newClear(6);

		grainViews = Array.newClear(6);
		playBufViews = Array.newClear(6);
		warpViews = Array.newClear(6);
		imageControlViews = Array.newClear(6);
		recViews = Array.newClear(6);
		latchViews = Array.newClear(6);
		latchSynthViews = Array.newClear(6);
		imageSynthViews = Array.newClear(6);

		outSels = Array.newClear(6);
		outLevelMeters = Array.newClear(6);
		outLevelMons = Array.newClear(6);
		ampSliders = Array.newClear(6);
		verbSends = Array.newClear(6);
		delaySends = Array.newClear(6);
		reverbSendBackgrounds = Array.newClear(6);
		delaySendBackgrounds = Array.newClear(6);

		trigSliders  = Array.newClear(6);
		rateSliders  = Array.newClear(6);
		durSliders  = Array.newClear(6);
		panSliders  = Array.newClear(6);
		centerPosSliders  = Array.newClear(6);
		selectionSpecs  = Array.newClear(6);

		playBufRates = Array.newClear(6);
		playBufTrigs = Array.newClear(6);
		playBufStartPoses = Array.newClear(6);
		playBufLoops = Array.newClear(6);
		playBufPans = Array.newClear(6);

		warpScaleSizes = Array.newClear(6);
		warpWindowRands = Array.newClear(6);
		warpOverlaps = Array.newClear(6);
		warpPans = Array.newClear(6);

		tuneAmounts = Array.newClear(6);
		sinAmps = Array.newClear(6);
		cutoffAmounts = Array.newClear(6);
		qAmounts = Array.newClear(6);
		imageFiltVols = Array.newClear(6);
		imageDistortMenus = Array.newClear(6);
		imageFilterMenus = Array.newClear(6);


		recButtons = Array.newClear(6);
		recSynths = Array.newClear(6);
		inChMenus = Array.newClear(6);
		recStartTimes = Array.newClear(6);
		loadFileA = Array.newClear(6);
		inputGains = Array.newClear(6);

		meters = Array.newClear(6);
		meterSynths = Array.newClear(6);
		monBusses = Array.newClear(6);
		// monitor busses
		6 .do({|i| monBusses[i] = Bus.audio(s, 2)});

		jumpMenus = Array.newClear(6);


		images = Array.newClear(6);
		imageBrightnessDatas = Array.newClear(6);
		imageScanRoutines = Array.newClear(6);
		imageReadyToLoads = Array.newClear(6);
		imageScanSpeeds = Array.newClear(6);
		imageScanRows = Array.fill(6, {0.5});
		imageR_Datas = Array.newClear(6);
		imageG_Datas = Array.newClear(6);
		imageB_Datas = Array.newClear(6);
		imageLagTimes = Array.newClear(6);
		imageScanWobble = Array.newClear(6);

		imageSynthModes = Array.newClear(6);


		latchPulseWidths = Array.newClear(6);
		latchNHarms = Array.newClear(6);
		latchOscMenus = Array.newClear(6);
		latchPWLabels = Array.newClear(6);
		latchNHarmLabels = Array.newClear(6);
		latchFormFreqs = Array.newClear(6);
		latchBwFreqs = Array.newClear(6);
		latchFormFreqLabels = Array.newClear(6);
		latchBwFreqLabels = Array.newClear(6);
		latchCoarseA = Array.newClear(6);
		latchPmRatios = Array.newClear(6);
		latchPmIndexs = Array.newClear(6);
		latchPmRatioLabels = Array.newClear(6);
		latchPmIndexLabels = Array.newClear(6);
		latchFbs = Array.newClear(6);
		latchFbLabels = Array.newClear(6);

		latchTrigSpeeds = Array.newClear(6);
		latchFreqAAs = Array.newClear(6);
		latchFreqBAs = Array.newClear(6);
		latchSpeeds = Array.newClear(6);
		latchSpeedLabels = Array.newClear(6);
		latchPatMenus = Array.newClear(6);
		latchTrigMenus = Array.newClear(6);
		latchFilterMenus = Array.newClear(6);
		latchCuts = Array.newClear(6);
		latchQs = Array.newClear(6);
		latchDetunes = Array.newClear(6);
		latchDistortMenus = Array.newClear(6);
		latchDistAmps = Array.newClear(6);







		imageSynthDefs = [\imageSineA, \imageSineRGBA, \ksPluckA, \imageSawA, \imageSquareA];
		imageSynthTrig = [false,        false,      true,    false,      false];





		6.do({|i|
			var rowY = 10 + (i * 170);

			soundFileViews[i] = SoundFileView(win, Rect(10, rowY, sfViewWidth, sfViewHeight))
			.gridOn_(true)
			.timeCursorOn_(true)
			.timeCursorColor_(Color.white)
			.timeCursorPosition_(100);
			soundFileViews[i].visible_(true);

			subwins[i] = CompositeView(win, Rect(sfViewWidth+20, rowY, sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.yellow(0.3));
		});

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

		6.do({|i|


			posSliderViews[i] = CompositeView(win, Rect(10, 115 + (i*170), sfViewWidth, 40))
			.background = Color.yellow(0.5);
			posSliderViews[i].visible_(true);

		});






		// ---------- Master channel window ------------------------------

		masterWin = CompositeView(win, Rect(1270, 10, 440, 995))
		.background=Color.yellow(0.5);


		// Quit program button
		quitButton=Button(masterWin, Rect(340, 10, 90, 60))
		.states_([["QUIT ENGINE!", Color.white, Color.red]])
		.action_({
			6.do({|chan|
				if(imageScanRoutines[chan].notNil){imageScanRoutines[chan].stop;imageScanRoutines[chan]=nil};
			});
			if(masterMeter.notNil){masterMeter.remove; masterMeter=nil};
			s.quit;
			win.close;

		});



		//----------------------------------------------------------------
		//---------------------- Synth A view ----------------------------
		//----------------------------------------------------------------


		// --------- SynthA  Gui window ---------------------



		6.do({|i|

			grainViews[i] = CompositeView(subwins[i], Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.yellow(0.7));
			grainViews[i].visible_(true);

			playBufViews[i] = CompositeView(subwins[i], Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.red(0.8, 0.6));
			playBufViews[i].visible_(false);

			warpViews[i] = CompositeView(subwins[i], Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.magenta(0.9,0.3));
			warpViews[i] .visible_(false);


			imageControlViews[i] = CompositeView(subwins[i],Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.grey(0.6, 0.4));
			imageControlViews[i].visible_(false);

			recViews[i] = CompositeView(subwins[i], Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.blue(0.9, 0.4));
			recViews[i].visible_(false);

			latchViews[i] = CompositeView(subwins[i], Rect(0,0,sfViewWidth/1.3, sfViewHeight+45))
			.background_(Color.new(0.9, 0.3, 0.0, 0.7));
			latchViews[i].visible_(false);



			// popummenuA
			typeMenus[i] = PopUpMenu(subwins[i], Rect(5, 10, 70, 30))
			.items_(["Grains", "Loop", "Warp", "Image", "Record", "Seq-S&H"])
			.action_({
				|menu|
				startButtons[i].visible_(menu.value !=4);
				switch(menu.value,
					0,{ // grain player view
						grainViews[i].visible_(true);
						playBufViews[i].visible_(false);
						warpViews[i].visible_(false);
						imageControlViews[i].visible_(false);
						soundFileViews[i].visible_(true);
						centerPosSliders[i].visible_(true); // show the loop slider
						posSliderViews[i].visible_(true);
						imageSynthViews[i].visible_(false);
						recViews[i].visible_(false);
						latchViews[i].visible_(false);
						latchSynthViews[i].visible_(false);


					},
					1,{ // playbuf player view
						grainViews[i].visible_(false);
						playBufViews[i].visible_(true);
						warpViews[i].visible_(false);
						imageControlViews[i].visible_(false);
						soundFileViews[i].visible_(true);
						centerPosSliders[i].visible_(false); // disable the loop slider
						posSliderViews[i].visible_(false);
						imageSynthViews[i].visible_(false);
						recViews[i].visible_(false);
						latchViews[i].visible_(false);
						latchSynthViews[i].visible_(false);

					},
					2,{ // warp player view
						grainViews[i].visible_(false);
						playBufViews[i].visible_(false);
						warpViews[i].visible_(true);
						imageControlViews[i].visible_(false);
						soundFileViews[i].visible_(true);
						centerPosSliders[i].visible_(false); // disable the loop slider
						posSliderViews[i].visible_(false);
						imageSynthViews[i].visible_(false);
						recViews[i].visible_(false);
						latchViews[i].visible_(false);
						latchSynthViews[i].visible_(false);

					},
					3,{ // Image player view
						grainViews[i].visible_(false);
						playBufViews[i].visible_(false);
						warpViews[i].visible_(false);
						imageControlViews[i].visible_(true);
						soundFileViews[i].visible_(false);
						centerPosSliders[i].visible_(false); // disable the loop slider
						posSliderViews[i].visible_(false);
						imageSynthViews[i].visible_(true);
						recViews[i].visible_(false);
						latchViews[i].visible_(false);
						latchSynthViews[i].visible_(false);
					},
					4,{ // record buffer viiew
						grainViews[i].visible_(false);
						playBufViews[i].visible_(false);
						warpViews[i].visible_(false);
						imageControlViews[i].visible_(false);
						soundFileViews[i].visible_(false);
						centerPosSliders[i].visible_(false); // disable the loop slider
						posSliderViews[i].visible_(false);
						imageSynthViews[i].visible_(false);
						recViews[i].visible_(true);
						latchViews[i].visible_(false);
						latchSynthViews[i].visible_(false);

					},
					5,{ // seq S&H view
						grainViews[i].visible_(false);
						playBufViews[i].visible_(false);
						warpViews[i].visible_(false);
						imageControlViews[i].visible_(false);
						soundFileViews[i].visible_(false);
						centerPosSliders[i].visible_(false); // disable the loop slider
						posSliderViews[i].visible_(false);
						imageSynthViews[i].visible_(false);
						recViews[i].visible_(false);
						latchViews[i].visible_(true);
						latchSynthViews[i].visible_(true);

					}
				);
				log.("Selected: " ++ menu.item);
			});


			// Left hand windows
			// soundfile views & synth views

			//------------------- soundFileViewA window----------------------------


			// What to do when user selects portion of sound file directly
			// (i.e., on waveform, not using slider)  .>> code from Bruno Ruviaro Granular synth
			soundFileViews[i].mouseUpAction = {arg view;
				var loFrames, hiFrames, loSlider, hiSlider;
				loFrames = view.selection(0)[0];
				hiFrames = view.selection(0)[1] + loFrames;
				loSlider = selectionSpecs[i].unmap(loFrames);
				hiSlider = selectionSpecs[i].unmap(hiFrames);
				2.do{centerPosSliders[i].setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
			};


			//

			// image synth controls
			imageSynthViews[i] = CompositeView(win, Rect(10, 10+(i*170), sfViewWidth, sfViewHeight+45))
			.background_(Color.grey(0.6, 0.4));
			imageSynthViews[i].visible_(false);


			// latch/S&H Synth View
			latchSynthViews[i] = CompositeView(win, Rect(10, 10 +(i * 170), sfViewWidth, sfViewHeight+45))
			.background_(Color.new(0.9, 0.3, 0.0, 0.7));
			latchSynthViews[i].visible_(false);




			//----------------------------------------------------------------

			//----------------------------------------------------------------

			// function for the grain view to live inside a stack view

			//------------------- gui controls -------------------------
			// open buttons

			// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
			// https://sccode.org/1-4UF




			imageReadyToLoads[i] = false;
			loadFileA = {|path, onDone, chanIdx|
				// audio mode
				soundFiles[chanIdx] = SoundFile.new;
				soundFiles[chanIdx].openRead(path);
				buffers[chanIdx] = Buffer.readChannel(s, path, channels: [0], action:{{onDone.value}.defer});
				soundFileViews[chanIdx].soundfile_(soundFiles[chanIdx]);
				soundFileViews[chanIdx].read(0, soundFiles[chanIdx].numFrames);
				selectionSpecs[chanIdx] = ControlSpec(0, soundFiles[chanIdx].numFrames);
				soundFileViews[chanIdx].setSelection(0, selectionSpecs[chanIdx].map([0.1, 0.2]));
				soundFileViews[chanIdx].mouseUpAction.value(soundFileViews[chanIdx]);

			};
			openFiles[i] = Button(subwins[i], Rect(5, 50, 60, 30))
			.states_([["open file", Color.black, Color.gray]])
			.action_({
				var proceed = true;
				if(typeMenus[i].value == 3, {
					if(imageReadyToLoads[i].not, {
						log.("--- Image Mode: pick your row and synth mode first, then click Load again ---");
						imageReadyToLoads[i] = true;
						proceed = false;
					}, {
						imageReadyToLoads[i] = false;
					});
				}, {
					log.("Opening sound file for Player A");
				});
				if(proceed, {
					startButtons[i].value = 0;
					Dialog.openPanel(
						{|path|
							if(typeMenus[i].value == 3, {
								// image mode
								{ // defer for AppClock
									images[i] = Image.open(path);
									imageBrightnessDatas[i] = Array.fill(images[i].width, {|x|
										var col = images[i].getColor(x, imageScanRows[i].linlin(0, 1, 0, images[i].height - 1).asInteger);
										(col.red + col.green + col.blue) / 3;
									});
									imageR_Datas[i] = Array.fill(images[i].width, {|x|
										images[i].getColor(x, imageScanRows[i].linlin(0, 1, 0, images[i].height - 1).asInteger).red
									});
									imageG_Datas[i] = Array.fill(images[i].width, {|x|
										images[i].getColor(x, imageScanRows[i].linlin(0, 1, 0, images[i].height - 1).asInteger).green
									});
									imageB_Datas[i] = Array.fill(images[i].width, {|x|
										images[i].getColor(x, imageScanRows[i].linlin(0, 1, 0, images[i].height - 1).asInteger).blue
									});
									images[i].free;
									log.("Image loaded - % pixels".format(imageBrightnessDatas[i].size));
								}.defer;
							}, {
								loadFileA.(path, nil, i);
							});
						},
						{log.("cancelled")};
					);
				});
			});





			//-----------------------------------------------------------------------

			// position slider
			centerPosSliders[i] = RangeSlider(posSliderViews[i], Rect(10, 5,sfViewWidth-20, 30 ))
			.lo_(0.1)
			.hi_(0.9)
			.action_({|sl|
				var lo, hi, size;
				lo = selectionSpecs[i].map(sl.lo);
				hi = selectionSpecs[i].map(sl.hi);
				size = hi - lo;
				soundFileViews[i].setSelection(0, [lo, size]);
				if(startButtons[i].value==1, {synthsStart[i].set(
					\centerPosLo, centerPosInSecondsA.value(i)[0],
					\centerPosHi, centerPosInSecondsA.value(i)[1]
				)});
			})
			.visible_(true);




			//---------------------GRAIN CONTROLS------------------------------------
			// trigger range slider
			trigSliders[i] = EZRanger(
				parent: grainViews[i],
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
					if(startButtons[i].value==1,
						{synthsStart[i].set(\triggerLo, sl.lo, \triggerHi, sl.hi)});
				},
				initVal: [0.1,1],
				labelWidth: 50,
				unitWidth: 30
			);


			// .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

			//-----------------------------------------------------------------------

			// rate slider
			rateSliders[i] = EZRanger(
				parent: grainViews[i],
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
					if(startButtons[i].value ==1, {synthsStart[i].set(
						\rateLo, transpToRate.value(sl.lo),
						\rateHi, transpToRate.value(sl.hi))})
				},
				initVal: [0.3,1.5],
				labelWidth: 50,
				unitWidth: 30

			);
			//-----------------------------------------------------------------------

			// grain duration slider
			durSliders[i] = EZRanger(
				parent: grainViews[i],
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
					if(startButtons[i].value==1, {synthsStart[i].set(
						\durLo, sl.lo, \durHi, sl.hi)})},
				initVal: [0.01, 0.5],
				labelWidth: 50,
				unitWidth: 30);

			//-----------------------------------------------------------------------
			// pan position slider
			panSliders[i] = EZRanger(
				parent: grainViews[i],
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
					if(startButtons[i].value==1, {synthsStart[i].set(\panLo, sl.lo, \panHi, sl.hi)})
				},
				initVal: [-0.1,0.1],
				labelWidth: 50,
				unitWidth: 30
			);


			//-----------------------------------------------------------------------
			// ampslider - positioned on the master subwindow
			ampSliders[i] = EZRanger(
				parent: masterWin,
				bounds: Rect(10+(i*55), 10, 30, 300),
				label: "ch1",
				controlSpec: ControlSpec(
					minval:0.0,
					maxval: 1,
					warp: 'lin',
					step: 0.01,
					units: "dB"),
				action: {|sl|
					if(startButtons[i].value==1,{
						switch(typeMenus[i].value,
							0,{synthsStart[i].set(\ampLo, sl.lo, \ampHi, sl.hi)},
							1,{synthsStart[i].set(\playBufAmp, sl.hi)},
							2,{synthsStart[i].set(\warpAmp, sl.hi)},
							3,{if(synthsStart[i].notNil,{synthsStart[i].set(\imageAmp, sl.hi)})},
							5,{synthsStart[i].set(\latchAmp, sl.hi)};
						);
					})
				},
				initVal: [0.0,0.0],
				labelWidth: 30,
				unitWidth: 10,
				layout:'vert'
			);

			outLevelMeters[i] = LevelIndicator(masterWin, Rect(45+(i*55), 60,12,200))
			.drawsPeak_(true)
			.warning_(0.7)
			.critical_(0.9);

			// channel select out
			outSels[i] = PopUpMenu(masterWin, Rect(10 +(i*55), 315, 47, 22))
			.items_(
				(0..((s.options.numOutputBusChannels/2).asInteger - 1))
				.collect({|i| "Out " ++ (i*2+1) ++ "-" ++ (i*2+2)})
			)
			.action_({|menu|
				if(synthsStart[i].notNil, {synthsStart[i].set(\out, menu.value*2)});
				outLevelMons[i].set(\outBus, menu.value * 2);
			});




			//-------------------------------------------
			//-------------------------------------------
			//-------------------------------------------
			//-------------------------------------------

			//Playbuf controls


			// trigger button
			playBufTrigs[i] = Button(playBufViews[i], Rect(rangerXpos+60, 10, rangerWidth-70, 20))
			.states_([["Trigger", Color.black, Color.gray]])
			.mouseDownAction_({|btn|
				if(synthsStart[i].notNil){synthsStart[i].set(\playBufTrig, 1)};
				{synthsStart[i].set(\playBufTrig, 0)}.defer(0.05);

			});


			// rate slider
			playBufRates[i] = Slider(playBufViews[i], Rect(rangerXpos+60, 30, rangerWidth-70, 20))
			.action_({|sl|
				if(synthsStart[i].notNil)
				{synthsStart[i].set(\playBufRate, sl.value.linlin(0, 1, -1,2 ))}
			})
			.value_(2/3); // something is broken here. it plays either too fast or too slow
			StaticText(playBufViews[i], Rect(rangerXpos+20, 30, 30, 20))
			.string_("rate")
			.background_(Color.green(0.6,0.6))
			.align_(\center);


			// start position
			playBufStartPoses[i] = Slider(playBufViews[i], Rect(rangerXpos+60, 50, rangerWidth-70, 20))
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\playBufStartPos, sl.value.linlin(0, 1, 0, buffers[i].numFrames))
				}
			})
			.value_(0);
			StaticText(playBufViews[i], Rect(rangerXpos+20, 50, 30, 20))
			.string_("start")
			.background_(Color.green(0.6,0.6))
			.align_(\center);

			// panner
			playBufPans[i] = Slider(playBufViews[i], Rect(rangerXpos+60, 70, rangerWidth-70, 20))
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\playBufPan, sl.value.linlin(0, 1, -1, 1))}
			})
			.value_(0.5);
			StaticText(playBufViews[i], Rect(rangerXpos+20, 70, 30, 20))
			.string_("pan")
			.background_(Color.green(0.6,0.6))
			.align_(\center);

			// loop on / off
			playBufLoops[i] = Button(playBufViews[i], Rect(350, 100, 70, 40))
			.states_([["loop on", Color.black, Color.green],["Loop off",Color.black, Color.gray]])
			.action_({|btn|
				if(synthsStart[i].notNil,{
					if(btn.value==1,
						{synthsStart[i].set(\playBufLoop, 1)},
						{synthsStart[i].set(\playBufLoop, 0)}
					);
				});

			});



			//-------------------------------------------
			//-------------------------------------------
			//-------------------------------------------

			//Warp1 controls

			warpScaleSizes[i] = Slider2D(warpViews[i] , Rect(350,5,170,110))
			.x_(0.5)
			.y_(0.5)
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\warpFreqScale, sl.x.linlin(0,1,-1,1), \warpWinSize,sl.y.linlin(0,1,1,0.1))
				}
			});
			StaticText(warpViews[i] , Rect(350, 115, 170, 20))
			.string_("x:freq scale / y:window size")
			.background_(Color.yellow(0.6,0.6))
			.align_(\center);

			warpOverlaps[i] = Slider(warpViews[i] , Rect(140,10,200,20))
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\warpOverlaps, sl.value.linlin(0,1,1,16))}
			})
			.value_(0.8);
			StaticText(warpViews[i] , Rect(85,10, 50, 15))
			.string_("overlaps")
			.background_(Color.yellow(0.6,0.6))
			.align_(\center);


			warpWindowRands[i] = Slider(warpViews[i] , Rect(140, 30, 200, 20))
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\warpWinRand, sl.value.linlin(0, 1, 0, 1))}
			});
			StaticText(warpViews[i] , Rect(85, 30, 50, 15))
			.string_("random")
			.background_(Color.yellow(0.6,0.6))
			.align_(\center);

			warpPans[i] = Slider(warpViews[i] , Rect(140, 50, 200, 20))
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\warpPan, sl.value.linlin(0, 1, -1,1))}
			})
			.value_(0.5);
			StaticText(warpViews[i] , Rect(85, 50, 50, 15))
			.string_("pan")
			.background_(Color.yellow(0.6,0.6))
			.align_(\center);


			//--------------------------------------------------------------
			// image scan A controls

			imageScanSpeeds[i] = Slider(imageControlViews[i], Rect(rangerXpos+60, 10, rangerWidth-70, 20))
			.value_(0.5);
			StaticText(imageControlViews[i], Rect(rangerXpos+10, 10, 45, 20))
			.string_("speed")
			.background_(Color.grey(0.6, 0.6))
			.align_(\center);

			// row selector buttons
			Button(imageControlViews[i], Rect(rangerXpos+240, 35, 50, 20))
			.states_([["Top", Color.black, Color.gray(0.6)]])
			.action_({imageScanRows[i] = 0.0});

			Button(imageControlViews[i], Rect(rangerXpos+295, 35, 50, 20))
			.states_([["Mid", Color.black, Color.gray(0.6)]])
			.action_({imageScanRows[i] = 0.5});

			Button(imageControlViews[i], Rect(rangerXpos+350, 35, 50, 20))
			.states_([["Bottom", Color.black,Color.gray(0.6)]])
			.action_({imageScanRows[i]=1.0});

			StaticText(imageControlViews[i], Rect(rangerXpos+10, 35, 215, 20))
			.string_("row - choose before opening file")
			.background_(Color.grey(0.6, 0.6))
			.align_(\center);



			// synth swap





			// toggle between  single and three tones
			imageSynthModes[i] = PopUpMenu(imageControlViews[i], Rect(rangerXpos+270, 60, 100, 20))
			.items_(["Sine", "SineRGB", "Pluck", "Saw", "Square"])
			.value_(0);

			StaticText(imageControlViews[i], Rect(rangerXpos+10, 60, 215, 20))
			.string_("mode - choose before opening file")
			.background_(Color.grey(0.6, 0.6))
			.align_(\center);


				// lag time slider
			imageLagTimes[i] = Slider(imageControlViews[i], Rect(rangerXpos+120, 81, 300, 20))
			.action_({|sl|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\lagTime, sl.value.linexp(0.001,1, 0.001, 2))
				}
			})
			.value_(0.001);
			StaticText(imageControlViews[i], Rect(rangerXpos+10, 81, 100, 20))
			.string_("portamento")
			.background_(Color.grey(0.6, 0.6))
			.align_(\center);


			// image scan wobble
			imageScanWobble[i] = Knob(imageControlViews[i], Rect(rangerXpos+420, 100, 40, 40))
			.value_(0);
			StaticText(imageControlViews[i], Rect(rangerXpos+310, 120, 100, 16))
			.string_("wobble")
			.background_(Color.grey(0.6, 0.6))
			.align_(\center);




			// image synth A Controls


			// course tuning
			tuneAmounts[i] = Knob(imageSynthViews[i], Rect(10, 10, 100, 100))
			.action_({|kn|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\tune, kn.value.linlin(0, 1, -1000,1000))
				}
			})
			.value_(0.5);

			StaticText(imageSynthViews[i], Rect(25, 115, 70, 20))
			.string_("tune")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 50);


			// amp into distortion
			sinAmps[i] = Knob(imageSynthViews[i], Rect(120, 10, 100, 100))
			.action_({|kb|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\sinAmp, kb.value.linlin(0,1,0,5))
				}
			})
			.value_(0.1);

			StaticText(imageSynthViews[i], Rect(120, 115, 100, 20))
			.string_("dist amount")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 50);


			// filter cutoff
			cutoffAmounts[i] = Knob(imageSynthViews[i], Rect(230, 10, 100, 100))
			.action_({|kb|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\cut, kb.value.linlin(0, 1, 0, 5000))
				}
			})
			.value_(1);

			StaticText(imageSynthViews[i], Rect(245, 115, 70, 20))
			.string_("cutoff")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 50);


			// filter resonance
			// note: the RLPF q us backwared
			// the other 2 filters is normal,
			// not sure how to rectify this
			qAmounts[i] = Knob(imageSynthViews[i], Rect(340, 10, 100, 100))
			.action_({|kn|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\q, kn.value.linlin(0, 1, 1, 0))
				}
			})
			.value_(0.5);

			StaticText(imageSynthViews[i], Rect(355, 115, 70, 20))
			.string_("resonance")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 50);

			// filter volume
			imageFiltVols[i] =Knob(imageSynthViews[i], Rect(450, 10, 100, 100))
			.action_({|kn|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\filtVol, kn.value.linlin(0.001,1,0,2))
				}
			})
			.value_(0.5);
			StaticText(imageSynthViews[i], Rect(455, 115, 90, 20))
			.string_("filter vol")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 50);




			// distortion type menu
			imageDistortMenus[i]=PopUpMenu(imageSynthViews[i], Rect(600, 10, 70, 30))
			.items_(["Clean","Clip", "Fold", "Wrap"])
			.action_({|menu|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\distortType, menu.value)
				}
			});

			StaticText(imageSynthViews[i], Rect(570, 45, 120, 20))
			.string_("distortion type")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 30);


			// filter type menu
			imageFilterMenus[i] = PopUpMenu(imageSynthViews[i],Rect(600, 80, 70, 20))
			.items_(["RLPF", "DFM1", "MoogVCF"])
			.action_({|menu|
				if(synthsStart[i].notNil){
					synthsStart[i].set(\filterType, menu.value)
				}
			});
			StaticText(imageSynthViews[i], Rect(570, 105, 120, 20))
			.string_("filter type")
			.background_(Color.green(0.9,0.9))
			.align_(\center)
			.font_("Monaco", 30);


			//----------------------------------------------------------------------------

			// Record buffer controls

			// record button
			recButtons[i] = Button(recViews[i], Rect(70, 50, 70, 30))
			.states_([["● Rec", Color.white, Color.red], ["■ Stop", Color.black, Color.gray]])
			.action_({|btn|
				if(btn.value==1){
					recStartTimes[i] = Main.elapsedTime;
					buffers[i] = Buffer.alloc(s, s.sampleRate*30, 1); // 30 sec mono buffer
					recSynths[i] = Synth(\recBufA, [\bufnum, buffers[i], \inCh, inChMenus[i].value, \inGain, inputGains[i].value.linlin(0, 1, -20, 20).dbamp]);
				}{
					var recFrames = ((Main.elapsedTime - recStartTimes[i])*s.sampleRate).asInteger.min(buffers[i].numFrames);

					var path = Platform.defaultTempDir +/+ "marrsRecA.wav";
					var oldBuf = buffers[i];
					recSynths[i].free;
					log.("recorded " ++ (Main.elapsedTime - recStartTimes[i]).round(0.01) ++ "s");
					{
						oldBuf.write(path, "wav", "int16", recFrames);
						s.sync;
						oldBuf.free;
						{loadFileA.(path, {
							typeMenus[i].valueAction_(jumpMenus[i].value);
							startButtons[i].valueAction_(1);
						}, i);
						}.defer;
					}.fork;
				};
			});


			inChMenus[i] = PopUpMenu(recViews[i], Rect(80, 10, 70, 30))
			.items_((1..s.options.numInputBusChannels).collect({|i| "In " ++ i}));

			StaticText(recViews[i], Rect(10, 10, 55, 26))
			.string_("input")
			.align_(\right);


			jumpMenus[i] = PopUpMenu(recViews[i], Rect(250, 10, 90, 26))
			.items_(["Grains", "Loop", "Warp"]);
			StaticText(recViews[i], Rect(155, 10, 90, 30))
			.string_("Send recording to ->")
			.background_(Color.yellow(0.8, 0.6));

			// level meter
			meters[i] = LevelIndicator(recViews[i], Rect(520, 10, 10, 130));

			// input gain knob
			inputGains[i] = Knob(recViews[i], Rect(380, 5, 100, 100))
			.action_({|kb|
				var gain = kb.value.linlin(0, 1, -20, 20).dbamp;
				if(recSynths[i].notNil, {recSynths[i].set(\inGain, gain)});
				meterSynths[i].set(\inGain, gain);
			})
			.value_(0.5);

			StaticText(recViews[i], Rect(380, 110, 50, 20))
			.string_("gain")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center);

			//----------------------------------------------------------------------------



			// Seq A = Sample & Hold controls

			latchTrigSpeeds[i] = Slider(latchViews[i], Rect(rangerXpos+90, 7, rangerWidth-100, 20))
			.action_({|sl|
				synthsStart[i].set(\trigSpeed, sl.value.linlin(0, 1, 0.5, 20))
			})
			.value_(0.2);
			StaticText(latchViews[i], Rect(rangerXpos+20, 9, 70,16))
			.string_("t_Speed")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center)
			.font_("Monaco", 30);

			latchFreqAAs[i] = Slider(latchViews[i],Rect(rangerXpos+90, 28, rangerWidth-100, 20))
			.action_({|sl|
				synthsStart[i].set(\latchFreqA, sl.value.linlin(0, 1, 50, 2000))
			})
			.value_(0.43);
			StaticText(latchViews[i], Rect(rangerXpos+20, 30, 70,16))
			.string_("freqA")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center)
			.font_("Monaco", 30);

			latchFreqBAs[i] = Slider(latchViews[i],Rect(rangerXpos+90, 49, rangerWidth-100, 20))
			.action_({|sl|
				synthsStart[i].set(\latchFreqB, sl.value.linlin(0, 1, 50, 2000))
			})
			.value_(0.23);
			StaticText(latchViews[i], Rect(rangerXpos+20, 51, 70,16))
			.string_("freqB")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center)
			.font_("Monaco", 30);

			latchSpeeds[i] = Slider(latchViews[i],Rect(rangerXpos+90, 70, rangerWidth-100, 20))
			.action_({|sl|
				synthsStart[i].set(\patSpeed, sl.value.linlin(0, 1, 0.1, 20))
			})
			.value_(0.05);

			latchSpeedLabels[i]=StaticText(latchViews[i], Rect(rangerXpos+20, 72, 70,16))
			.string_("pat spd")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center)
			.font_("Monaco", 30);


			latchPatMenus[i] = PopUpMenu(latchViews[i], Rect(rangerXpos+360, 93, 80, 20))
			.items_(["Sine", "Tri", "Saw", "Pulse", "Noise0", "Noise1", "Noise2"])
			.action_({|menu|
				synthsStart[i].set(\patType, menu.value);
				latchSpeeds[i].visible_(menu.value < 4);
				latchSpeedLabels[i].visible_(menu.value < 4);
			});
			StaticText(latchViews[i], Rect(rangerXpos+280, 93, 70, 16))
			.string_("pat type")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center)
			.font_("Monaco", 30);


			latchTrigMenus[i] = PopUpMenu(latchViews[i], Rect(rangerXpos+360, 114, 80, 20))
			.items_(["Impulse", "Dust"])
			.action_({|menu|
				synthsStart[i].set(\trigType, menu.value)
			});
			StaticText(latchViews[i], Rect(rangerXpos+280, 114, 70, 16))
			.string_("trig type")
			.background_(Color.grey(0.7, 0.5))
			.align_(\center)
			.font_("Monaco", 30);






			// latch synth controls






			latchOscMenus[i] = PopUpMenu(latchSynthViews[i], Rect(85, 10, 70, 22))
			.items_(["Sine", "Tri", "Saw", "Pulse", "Blip", "Formant", "Phase Modulation", "SineFB"])
			.action_({|menu|
				synthsStart[i].set(\oscType, menu.value);
				latchPulseWidths[i].visible_(menu.value == 3);
				latchPWLabels[i].visible_(menu.value == 3);
				latchNHarms[i].visible_(menu.value == 4);
				latchNHarmLabels[i].visible_(menu.value == 4);
				latchFormFreqs[i].visible_(menu.value == 5);
				latchFormFreqLabels[i].visible_(menu.value == 5);
				latchBwFreqs[i].visible_(menu.value == 5);
				latchBwFreqLabels[i].visible_(menu.value == 5);
				latchPmRatios[i].visible_(menu.value == 6);
				latchPmRatioLabels[i].visible_(menu.value == 6);
				latchPmIndexs[i].visible_(menu.value == 6);
				latchPmIndexLabels[i].visible_(menu.value == 6);
				latchFbs[i].visible_(menu.value == 7);
				latchFbLabels[i].visible_(menu.value == 7);



			});
			StaticText(latchSynthViews[i], Rect(10, 10, 70, 22))
			.string_("osc type")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);




			latchCoarseA[i] = Knob(latchSynthViews[i], Rect(10, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\coarse, kb.value.linlin(0, 1, -24, 24).round(1))
			})
			.value_(0.5);
			StaticText(latchSynthViews[i], Rect(20, 110, 50, 30))
			.string_("coarse tune")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);


			latchDetunes[i] = Knob(latchSynthViews[i], Rect(90, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\detune, kb.value.linlin(0, 1, 0, 0.02))
			})
			.value_(0);

			StaticText(latchSynthViews[i], Rect(100, 110, 50, 30))
			.string_("detune")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			//-------- distortion controls

			latchDistortMenus[i] = PopUpMenu(latchSynthViews[i], Rect(230, 10, 70, 22))
			.items_(["Clean", "Clip", "Fold", "Warp"])
			.action_({|menu|
				synthsStart[i].set(\distType, menu.value)
			});

			StaticText(latchSynthViews[i], Rect(165, 10, 60, 22))
			.string_("distort")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			latchDistAmps[i] = Knob(latchSynthViews[i], Rect(190, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\distAmp, kb.value.linlin(0, 1, 0, 2))
			})
			.value_(0.1);

			StaticText(latchSynthViews[i], Rect(175, 110, 100, 30))
			.string_("distortion drive")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);





			// Pulse width Knob

			latchPulseWidths[i] = Knob(latchSynthViews[i], Rect(350, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\pulseWidth, kb.value.linlin(0,1,0,1))
			})
			.value_(0.5);

			latchPWLabels[i]=StaticText(latchSynthViews[i], Rect(340, 110, 100, 30))
			.string_("pulse width")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			// Blip Harmonics knob

			latchNHarms[i] = Knob(latchSynthViews[i], Rect(350, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\nHarm, kb.value.linlin(0,1,0,30).round(1))})
			.value_(0.1);

			latchNHarmLabels[i]=StaticText(latchSynthViews[i], Rect(340, 110, 90, 30))
			.string_("harmonics")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			// formant  controls
			latchFormFreqs[i] = Knob(latchSynthViews[i], Rect(310, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\formFreq, kb.value.linexp(0.001,1,100, 5000))
			})
			.value_(0.5);

			latchFormFreqLabels[i] = StaticText(latchSynthViews[i], Rect(300, 110, 90, 30))
			.string_("form freq")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			latchBwFreqs[i] = Knob(latchSynthViews[i], Rect(410, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\bwFreq, kb.value.linexp(0.001, 1, 50, 2000))
			})
			.value_(0.5);

			latchBwFreqLabels[i] = StaticText(latchSynthViews[i], Rect(400, 110, 90, 30))
			.string_("bandwidth")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			// PMOsc Controls
			latchPmRatios[i] = Knob(latchSynthViews[i], Rect(310, 40, 70, 70 ))
			.action_({|kb|
				synthsStart[i].set(\pmRatio, kb.value.linlin(0, 1, 1, 8))
			})
			.value_(0);

			latchPmRatioLabels[i] = StaticText(latchSynthViews[i], Rect(300, 110, 90, 30))
			.string_("pm ratio")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);


			latchPmIndexs[i] = Knob(latchSynthViews[i], Rect(410, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\pmIndex, kb.value.linlin(0, 1, 0, 12))
			})
			.value_(0.08);

			latchPmIndexLabels[i]  = StaticText(latchSynthViews[i], Rect(400, 110, 90, 30))
			.string_("pm index")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);


			//------- SinOscFB control

			latchFbs[i] = Knob(latchSynthViews[i], Rect(350, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\fbAmount, kb.value.linlin(0, 1, 0, 4))
			})
			.value_(0.08);

			latchFbLabels[i]  = StaticText(latchSynthViews[i], Rect(330, 110, 100, 30))
			.string_("feedback")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);





			//------- filter
			latchFilterMenus[i] = PopUpMenu(latchSynthViews[i], Rect(620, 10, 70, 20))
			.items_(["RLPF", "RHPF", "DFM1", "MoofVCF", "MoogLadder", "GlitchRHPF-CAREFUL-LOUD!!", "Resonz"])
			.action_({|menu|
				synthsStart[i].set(\filterType, menu.value);
				{
					latchQs[i].valueAction_(if(menu.value <=1, 1, 0));
				}.defer;
			});
			StaticText(latchSynthViews[i], Rect(550, 10, rangerXpos-5, 20))
			.string_("filter")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			latchCuts[i] = Knob(latchSynthViews[i], Rect(550, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\cut, kb.value.linexp(0.001, 1, 20, 20000));
			})
			.value_(0.5);
			StaticText(latchSynthViews[i], Rect(550, 120, rangerXpos-5, 18))
			.string_("cutoff")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);



			latchQs[i] = Knob(latchSynthViews[i], Rect(630, 40, 70, 70))
			.action_({|kb|
				synthsStart[i].set(\q, kb.value.linlin(0, 1, 0, 1))
			})
			.value_(1);
			StaticText(latchSynthViews[i], Rect(630, 120, rangerXpos-5, 18))
			.string_("rez")
			.background_(Color.grey(0.7, 0.7))
			.align_(\center)
			.font_("Monaco", 30);





			// visibility

			latchPulseWidths[i].visible_(false);
			latchPWLabels[i].visible_(false);
			latchNHarms[i].visible_(false);
			latchNHarmLabels[i].visible_(false);
			latchFormFreqs[i].visible_(false);
			latchFormFreqLabels[i].visible_(false);
			latchBwFreqs[i].visible_(false);
			latchBwFreqLabels[i].visible_(false);
			latchPmRatios[i].visible_(false);
			latchPmRatioLabels[i].visible_(false);
			latchPmIndexs[i].visible_(false);
			latchPmIndexLabels[i].visible_(false);
			latchFbs[i].visible_(false);
			latchFbLabels[i].visible_(false);

			//----------------------------------------------------------------------------
			//----------------------------------------------------------------------------
			//----------------------------------------------------------------------------
			//----------------------------------------------------------------------------



			//reverb send knob
			reverbSendBackgrounds[i]=CompositeView(subwins[i], Rect(120, 103, 100, 40))
			.background_(Color.cyan(0.4));

			verbSends[i] = Knob(reverbSendBackgrounds[i],Rect(5, 5, 30, 30))
			.action_({|kn|
				synthsStart[i].set(\verbSend, kn.value.linlin(0, 1, 0, 1))
			});
			StaticText(reverbSendBackgrounds[i], Rect(30, 5, 70, 30))
			.string_("reverb send")
			.align_(\center);


			//delay send knob
			delaySendBackgrounds[i] =CompositeView(subwins[i], Rect(230, 103, 100, 40))
			.background_(Color.cyan(0.4));


			delaySends[i] = Knob(delaySendBackgrounds[i],Rect(5, 5, 30, 30))
			.action_({|kn|
				synthsStart[i].set(\delaySend, kn.value.linlin(0, 1, 0, 1))
			});
			StaticText(delaySendBackgrounds[i], Rect(35, 5, 60, 30))
			.string_("delay send")
			.align_(\center);



			//-----------------------------------------------------------------------
			// start button
			// code block taken from Bruno Ruviaro Granular Sampling Patch 1 and adapted.
			// https://sccode.org/1-4UF


			startButtons[i] = Button(subwins[i], Rect(5, 90, 60, 30))
			.states_([["START", Color.black, Color.green], ["STOP", Color.black, Color.red]])
			.action_({
				arg button;
				// Is the button being pressed (1) or released/stopped (0)?
				if(button.value == 1,
					// --- PRESSED ---
					{
						// A file IS loaded — now check which synth type is selected
						switch(typeMenus[i].value,
							// Menu is on Grains (index 0) — fire TGrains
							0,{
								// First, check if a file has been loaded into the buffer.
								// buffers[i].isNil means "bufferA has nothing in it yet"
								if(buffers[i].isNil,
									// No file loaded — warn the user and reset the button
									{
										log.("Please load a file first!");
										button.value_(0); // un-press the button visually
									},{
										synthsStart[i] = Synth(\tgrainsPlayerA, [
											\triggerLo,   trigSliders[i].lo,
											\triggerHi,   trigSliders[i].hi,
											\rateLo,      transpToRate.value(rateSliders[i].lo),
											\rateHi,      transpToRate.value(rateSliders[i].hi),
											\centerPosLo, centerPosInSecondsA.value(i)[0],
											\centerPosHi, centerPosInSecondsA.value(i)[1],
											\durLo,       durSliders[i].lo,
											\durHi,       durSliders[i].hi,
											\panLo,       panSliders[i].lo,
											\panHi,       panSliders[i].hi,
											\ampLo,       ampSliders[i].lo,
											\ampHi,       ampSliders[i].hi,
											\bufnum,      buffers[i],
											\verbSend,    verbSends[i].value,
											\delaySend,   delaySends[i].value,
											\out,         outSels[i].value * 2,
											\monBus, monBusses[i],
										]);
										log.("TGrains playing");
								});
							},


							// Menu is on Loop (index 1) — fire PlayBuf
							1,{
								if(buffers[i].isNil,
									{ log.("Please load a file first");
										button.value_(0);
									},{
										synthsStart[i] = Synth(\playBufferA, [
											\bufnum,     buffers[i],
											\playBufRate,playBufRates[i].value.linlin(0,1,-1,2),
											\playBufAmp, ampSliders[i].lo,
											\playBufPan, playBufPans[i].value.linlin(0,1,-1,1),
											\playBufStartPos, 0.0,
											\playBufTrig, 0,
											\playBufLoop, 1,
											\verbSend,  verbSends[i].value,
											\delaySend, delaySends[i].value,
											\out,         outSels[i].value * 2,
											\monBus, monBusses[i],
										]);
										log.("PlayBuf playing");
								});
							},


							2,{// menu is on warp (index 2)
								if(buffers[i].isNil,
									{ log.("Please load a file first");
										button.value_(0);
									},{

										synthsStart[i] = Synth(\warpBufferA,[
											\bufnum, buffers[i],
											// \warpPointer,
											\warpFreqScale,warpScaleSizes[i].x.linlin(0,1,-10,10),
											\warpWinSize, warpScaleSizes[i].y.linlin(0, 1, 0.01,4),
											\warpPan, warpPans[i].value.linlin(0,1,-1,1),
											\warpOverlaps, warpOverlaps[i].value.linlin(0,1,1,16),
											\warpWinRand,warpWindowRands[i].value,
											\warpAmp, ampSliders[i].lo,
											\verbSend, verbSends[i].value,
											\delaySend, delaySends[i].value,
											\out,         outSels[i].value * 2,
											\monBus, monBusses[i],

										]);
										log.("Warp buffer Playing");
								});
							},


							3,{
								// menu is on image (index 3)
								if(imageBrightnessDatas[i].isNil, {
									log.("Load an image first");
									button.value_(0);
								},{
									var amp = ampSliders[i].hi;
									var verbSend = verbSends[i] .value;
									var delaySend = delaySends[i].value;
									var mode = imageSynthModes[i].value;
									var tune = tuneAmounts[i].value.linlin(0, 1, -1000,1000);
									var sinAmp = sinAmps[i].value.linlin(0, 1, 0, 5);
									var cut = cutoffAmounts[i].value.linlin(0, 1, 0, 5000);
									var q = qAmounts[i].value.linlin(0, 1, 1, 0);
									var filtVol = imageFiltVols[i].value.linlin(0.001, 1, 0, 2);
									var distortType = imageDistortMenus[i].value;
									var filterType = imageFilterMenus[i].value;

									imageScanRoutines[i] = Routine({
										imageBrightnessDatas[i].size.do({|px|
											var freq = imageBrightnessDatas[i][px].max(0.001).linexp(0.001,1,80,4000);
											var freqR = imageR_Datas[i][px].max(0.001).linexp(0.001,1,80, 4000);
											var freqG = imageG_Datas[i][px].max(0.001).linexp(0.001,1,80, 4000);
											var freqB = imageB_Datas[i][px].max(0.001).linexp(0.001,1,80, 4000);
											var speed = imageScanSpeeds[i].value.linlin(0, 1, 3, 0.01);
											var wobble = imageScanWobble[i].value.linlin(0, 1, 0, 2.5);

											{
												var args = [
													\freq, freq,
													\freqR, freqR,
													\freqG, freqG,
													\freqB, freqB,
													\imageAmp, ampSliders[i].hi,
													\tune, tuneAmounts[i].value.linlin(0, 1, -1000,1000),
													\sinAmp, sinAmps[i].value.linlin(0, 1, 0, 5),
													\cut, cutoffAmounts[i].value.linlin(0, 1, 0, 5000),
													\q, qAmounts[i].value.linlin(0, 1, 1, 0),
													\filtVol, imageFiltVols[i].value.linlin(0.001, 1, 0, 2),
													\distortType, imageDistortMenus[i].value,
													\filterType, imageFilterMenus[i].value,
													\verbSend, verbSends[i].value,
													\delaySend, delaySends[i].value,
													\out,         outSels[i].value * 2,
													\monBus, monBusses[i],
													\lagTime, imageLagTimes[i].value.linexp(0.001, 1, 0.001, 2),
												];
												if(imageSynthTrig[mode],{
													//triggered: a fresh synth every pixel (frees itself)
													Synth(imageSynthDefs[mode], args);
												},{
													// held: make one, then slide its pitch
													if(synthsStart[i].isNil,{
														synthsStart[i] = Synth(imageSynthDefs[mode], args);
													},{
														synthsStart[i].set(\freq, freq, \freqR, freqR, \freqG, freqG, \freqB, freqB);

													});
												});
											}.defer;

											rrand(speed*(1-wobble), speed*(1+wobble)).wait;
										});
										log.("Scan Complete");
									}).play(AppClock);
									// should end here???
								});
							},
							4,{ // menu item 4 - Record


							},
							5,{// menu is on item 5 - seq S&H
								synthsStart[i] = Synth(\latchSeqA, [
									\trigSpeed, latchTrigSpeeds[i].value.linlin(0, 1, 0.5, 20),
									\coarse, latchCoarseA[i].value.linlin(0, 1, -24, 24).round(1),
									\detune, latchDetunes[i].value.linlin(0, 1, 0, 0.02),
									\latchFreqA, latchFreqAAs[i].value.linlin(0, 1, 50, 400),
									\latchFreqB, latchFreqBAs[i].value.linlin(0, 1, 50, 2000),
									\patSpeed, latchSpeeds[i].value.linlin(0, 1, 0.1, 20),
									\latchAmp, ampSliders[i].hi,
									\verbSend, verbSends[i].value,
									\delaySend, delaySends[i].value,
									\oscType, latchOscMenus[i].value,
									\pulseWidth, latchPulseWidths[i].value,
									\nHarm, latchNHarms[i].value.linlin(0,1, 1,30),
									\patType, latchPatMenus[i].value,
									\trigType, latchTrigMenus[i].value,
									\filterType, latchFilterMenus[i].value,
									\distType, latchDistortMenus[i].value,
									\distAmp, latchDistAmps[i].value.linlin(0, 1, 0, 2),
									\cut, latchCuts[i].value.linexp(0.001,1,20,20000),
									\q, latchQs[i].value,
									\formFreq, latchFormFreqs[i].value.linexp(0.001, 1, 100, 5000),
									\bwFreq, latchBwFreqs[i].value.linexp(0.001,1, 50, 2000),
									\pmRatio, latchPmRatios[i].value.linlin(0, 1, 1, 8),
									\pmIndex, latchPmIndexs[i].value.linlin(0, 1, 0, 4),
									\fbAmount, latchFbs[i].value.linlin(0, 1, 0, 4),
									\out, outSels[i].value * 2,
									\monBus, monBusses[i],

								]);
								log.("Sample & Hold Playing");

							};
						);
					},
					// --- RELEASED / STOPPED ---
					{
						if(imageScanRoutines[i].notNil,{
							imageScanRoutines[i].stop;
							imageScanRoutines[i] = nil;
						});
						if(synthsStart[i].notNil, {
							synthsStart[i].set(\gate, 0);
							synthsStart[i] = nil;
							log.("Player A has stopped");
						}, {
							log.("Nothing was playing");
						});
					}
				);
			});


		}); // end of loop







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
			arg out=0, gate =1, bufnum, triggerLo, triggerHi, rateLo,rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi, verbSend=0, delaySend=0,  monBus=0;

			var env,sig, grainSig, trig, triggerAmount, rate, dur, pan, amp, centerPos, wetVerb, wetDelay;

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
			Out.ar(monBus, grainSig);
			wetVerb = grainSig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = grainSig * delaySend;
			Out.ar(busDelay, wetDelay);
		}).add;


		//-------------------------------------------------------------------------------

		// Slot A Playbuf
		SynthDef(\playBufferA, {
			arg out=0, gate=1,bufnum,playBufRate=1,playBufAmp=1,playBufPan=0, verbSend=0, delaySend=0, playBufStartPos=0.0,playBufTrig=0, playBufLoop=1, monBus=0;
			var sig, env,wetVerb, wetDelay;
			env = EnvGen.kr(Env.asr(0.1,1,1),gate: gate,doneAction: 2);
			sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*playBufRate,trigger: playBufTrig,startPos: playBufStartPos, loop:playBufLoop);
			sig = Pan2.ar(sig, playBufPan, playBufAmp)*env;
			Out.ar(out, sig);
			Out.ar(monBus,sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;


		//-------------------------------------------------------------------------

		// Slot A Warp

		SynthDef(\warpBufferA, {
			arg out = 0, gate=1, bufnum,warpFreqScale=0.1,warpWinSize=0.2,warpPan=0.0,warpWinRand=0.1,warpOverlaps=8, warpAmp=0.3, verbSend=0, delaySend=0, monBus=0;
			var sig, env, wetVerb, wetDelay,warpPointer;
			warpPointer = LFSaw.ar(BufDur.kr(bufnum).reciprocal).range(0,1);
			env = EnvGen.kr(Env.asr(1,1,1),gate, doneAction: 2);
			sig = Warp1.ar(1,bufnum,warpPointer,warpFreqScale,warpWinSize,-1,warpOverlaps,warpWinRand,2,0.1)*env;
			sig = Pan2.ar(sig, warpPan, warpAmp);
			Out.ar(out, sig);
			Out.ar(monBus, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		//--------------------------------------------------

		// image Synth A

		SynthDef(\imageSineA, {
			arg out=0, freq = 440, tune=0,sinAmp=0.3, cut=5000,q=1, filtVol=1,imageAmp=0.3, distortType=0, filterType=0, imagePan=0.0, gate=1, verbSend=0,delaySend=0, monBus=0, lagTime=0;
			var sig, env, wetVerb, wetDelay;
			env = EnvGen.kr(Env.asr(1,1,1),gate, doneAction: 2);
			sig = SinOsc.ar(Lag.kr(freq+tune,lagTime),0,  sinAmp);

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
			Out.ar(monBus, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;


		// image RGB Sine

		SynthDef(\imageSineRGBA, {
			arg out=0, freqR=220, freqG=330, freqB=440,tune=0,sinAmp=0.3, distortType=0,filterType=0, filtVol=1,cut=5000,q=1, imageAmp=0.3,gate=1,verbSend=0,delaySend=0, monBus=0, lagTime=0;
			var  sig, env, wetVerb, wetDelay;
			env = EnvGen.kr(Env.asr(1,1,1),gate,doneAction:2);
			sig = Pan2.ar(SinOsc.ar(Lag.kr([freqR,freqG,freqB]+tune,lagTime), 0, sinAmp), [-0.8, 0.0, 0.8]);
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
			Out.ar(monBus, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);
		}).add;

		// image KS_Pluck from ixi tutorial 10
		SynthDef(\ksPluckA,{ arg out=0, freq=220, imagePan=0, rand=0.3, delayTime=3, noiseType=1, verbSend=0, delaySend=0, distortType=0, filterType=0, filtVol=1, cut=5000, q=1, sinAmp=0.3, tune=0, imageAmp=0.3, monBus=0;
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
			Out.ar(monBus, LeakDC.ar(sig));
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


		SynthDef(\imageSawA, {
			arg out=0, freqR=220, freqG=330, freqB=440, tune = 0, sinAmp=0.3, cut=5000, q=1, filtVol=1, imageAmp=0.3,imagePan=0, distortType=0, filterType=0, gate=1, verbSend=0, delaySend=0, monBus=0, lagTime=0;
			var sig, env, wetDelay, wetVerb;
			env = EnvGen.kr(Env.asr(1, 1, 1),gate, doneAction: 2);
			sig = Pan2.ar(Saw.ar(Lag.kr([freqR,freqG,freqB]+tune, lagTime), sinAmp), [-0.8, 0.0, 0.8]);
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
			Out.ar(monBus, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		SynthDef(\imageSquareA, {
			arg out=0, freqR=220, freqG=330, freqB=440, tune = 0, sinAmp=0.3, cut=5000, q=1, filtVol=1, imageAmp=0.3,imagePan=0, distortType=0, filterType=0, gate=1, verbSend=0, delaySend=0, monBus=0, lagTime=0;
			var sig, env, wetDelay, wetVerb;
			env = EnvGen.kr(Env.asr(1, 1, 1),gate, doneAction: 2);
			sig = Pan2.ar(Pulse.ar(Lag.kr([freqR,freqG,freqB]+tune, lagTime), 0.5, sinAmp),[-0.8, 0.0, 0.8]);
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
			Out.ar(monBus, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		SynthDef(\latchSeqA, {
			// need to add
			// trigger select
			// Osc select
			// latch in select

			arg out=0, latchFreqA=200, latchFreqB=500, patSpeed=1, trigSpeed=3, cut=1000,q=0.5, gate=1, verbSend=0,delaySend=0, latchAmp=1,pan=0.0, patType=0, trigType=0, oscType=0, filterType=0, distType=0, pulseWidth=0.5, nHarm=4, formFreq=1760, bwFreq=880, coarse=0, pmRatio=1, pmIndex=1, fbAmount=0.5, detune=0.0, distAmp=0.2, oscLag = 0.1, monBus=0;
			var sig, env1, env2, trig, wetDelay, wetVerb, filtMapped, qMapped;
			trig = Select.kr(trigType,[
				Impulse.kr(trigSpeed), // trigger select
				Dust.kr(trigSpeed),

			]);

			env1 = EnvGen.kr(Env.linen(0.01, 0.5, 0.1), trig);
			env2 = EnvGen.kr(Env.asr(0.1,1,0.5),gate, doneAction: 2);

			// pattern select
			sig = Select.kr( patType,[
				SinOsc.kr(patSpeed, 0, latchFreqA, latchFreqB),
				LFTri.kr(patSpeed, 0.0, latchFreqA, latchFreqB),
				LFSaw.kr(patSpeed, 0.0,latchFreqA, latchFreqB), // latch in select
				LFPulse.kr(patSpeed, 0.0, 0.5, latchFreqA, latchFreqB),
				LFNoise0.kr(trigSpeed,latchFreqA,latchFreqB),
				LFNoise1.kr(trigSpeed, latchFreqA,latchFreqB),
				LFNoise2.kr(trigSpeed, latchFreqA, latchFreqB)
			]);

			sig = Latch.kr(sig, trig*env1); // the actual S&H
			sig = sig * coarse.midiratio; // coarse detune
			sig = sig * [1 - detune, 1 + detune]; // fine detune -> chorusing

			// signal oscillator selection
			sig = SelectX.ar(Lag.kr(oscType, oscLag), [
				SinOsc.ar(sig, 0.0, distAmp)*env2,			// Osc select
				LFTri.ar(sig, 0.0, distAmp)*env2,
				Saw.ar(sig, distAmp )*env2,
				Pulse.ar(sig, pulseWidth, distAmp)*env2,
				Blip.ar(sig, nHarm, distAmp)*env2,
				Formant.ar(sig,formFreq, bwFreq, distAmp)*env2,
				PMOsc.ar(sig, sig*pmRatio, pmIndex, 0,distAmp)*env2,
				SinOscFB.ar(sig, fbAmount, distAmp)*env2

			]);

			sig = sig.sum * 0.5; // sum the signals up

			//distortion select
			sig = SelectX.ar(Lag.kr(distType,0.1),[
				sig,
				Clip.ar(sig, 0, 1),
				Fold.ar(sig, 0, 1),
				Wrap.ar(sig, 0, 1)
			]);

			//filter mapping
		/*	filtMapped = Select.kr(filterType, [
				cut.linlin(0, 1, 50, 5000),   // RLPF
				cut.linlin(0, 1, 5000, 50),   // RHPF
				cut.linlin(0, 1, 50, 5000),     // DFM1
				cut.linlin(0, 1, 50, 5000),   // MoogVCF
				cut.linlin(0, 1, 50, 5000),   // MoogLadder
				cut.linlin(0, 1, 5000, 50),   // GlitchRHPF
				cut.linlin(0, 1, 50, 5000),  // Resonz
			])*/

			// resonance mapping
			qMapped = Select.kr(filterType, [
				q.linlin(0, 1, 0.1, 1),   // RLPF
				q.linlin(0, 1, 0.1, 1),   // RHPF
				q.linlin(0, 1, 0, 1),     // DFM1
				q.linlin(0, 1, 0, 2.5),   // MoogVCF
				q.linlin(0, 1, 0, 0.9),   // MoogLadder
				q.linlin(0, 1, 1, 0.3),   // GlitchRHPF
				q.linlin(0, 1, 2, 0.05),  // Resonz
			]);

			// filter type selection
			sig = SelectX.ar(Lag.kr(filterType, 0.1), [
				RLPF.ar(sig, cut, qMapped),
				RHPF.ar(sig, cut, qMapped),
				DFM1.ar(sig, cut, qMapped),
				MoogVCF.ar(sig, cut, qMapped, 2),
				MoogLadder.ar(sig, cut, qMapped, 2),
				GlitchRHPF.ar(sig, cut, qMapped, 0.7),
				Resonz.ar(sig, cut, qMapped),
			]);

			sig = Pan2.ar(sig, pan, latchAmp);
			Out.ar(out, sig);
			Out.ar(monBus, sig);
			wetVerb = sig * verbSend;
			Out.ar(busReverb, wetVerb);
			wetDelay = sig * delaySend;
			Out.ar(busDelay, wetDelay);

		}).add;

		//-------------------------------------------------------------------------

		// recording buffer



		SynthDef(\recBufA, {
			arg bufnum, inCh = 0, inGain=1;
			var in = SoundIn.ar(inCh,inGain);
			RecordBuf.ar(in, bufnum, loop: 0, doneAction:2);
		}).add;


		// level meter

		SynthDef(\inMeterA, {
			arg inCh = 0, inGain=1.0, chanIdx=0;
			SendReply.kr(Impulse.kr(20), '/inAmp',
				Amplitude.kr(SoundIn.ar(inCh, inGain), 0.01,0.2),
				chanIdx)
		}).add;

		OSCdef(\inMeter, {|msg| {meters[msg[2]].value = msg[3]}.defer}, '/inAmp');


		//-------------------------------------------------------------------------

		// level metering
		SynthDef(\outLevelMonA, {|outBus=0, chanIdx=0|
			var sig = In.ar(outBus, 2);
			SendReply.kr(Impulse.kr(20), '/outAmpA',
				Amplitude.kr(sig.sum, 0.01, 0.1),
				chanIdx);
		}).add;

		OSCdef(\outMeterA,  {|msg| {outLevelMeters[msg[2]].value = msg[3]}.defer},'/outAmpA');


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


		//----------------------

		// meter levels - record in
		6.do({|i|
			meterSynths[i] = Synth(\inMeterA, [\inCh, inChMenus[i].value, \inGain, inputGains[i].value.linlin(0, 1, -20, 20).dbamp, \chanIdx, i]);
		});

		// meter levels  - mixer out
		6.do({|i|
			outLevelMons[i] = Synth(\outLevelMonA, [\outBus, monBusses[i], \chanIdx, i], addAction: \addToTail);
		});





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
					if(PathName(path).extension !="wav"){path = path ++ ".wav"};

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
			6.do({|chan|
				if(imageScanRoutines[chan].notNil,{imageScanRoutines[chan].stop; imageScanRoutines[chan]=nil;});
			});
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


