(
s.waitForBoot({
	var win, subwin, typeMenu;
	var grainView, playBufView;
	var bufferA, soundFileA, currentSynth, startButton, openFile;


	SynthDef(\tGrainsPlayer,{
		arg out=0,gate=1,bufnum=0,triggerLo=4,triggerHi=12,rateLo=1,rateHi=1,centerPosLo=0.0,centerPosHi=0.5,durLo=0.08,durHi=0.15,panLo= -0.5,panHi=0.5,ampLo=0.2,ampHi=1;
		var env, trig, sig;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate,doneAction: 2);
		trig = Impulse.kr(LFNoise0.kr(1).range(triggerLo, triggerHi));
    # rateLo, centerPosLo, durLo, panLo, ampLo = Demand.kr(trig, 0, [
        Dwhite(rateLo, rateHi),
        Dwhite(centerPosLo, centerPosHi),
        Dwhite(durLo, durHi),
        Dwhite(panLo, panHi),
        Dwhite(ampLo, ampHi)
    ]);
    sig = TGrains.ar(2, trig, bufnum,
        rateLo, centerPosLo, durLo, panLo, ampLo);
    Out.ar(out, sig * env);
}).add;

	SynthDef(\playBuffer, {
		arg out=0,gate=1,bufnum=0,rate=1,amp=1,pan=0;
		var env, sig;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate, doneAction: 2);
		sig = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum)*rate, loop:1);
		sig = Pan2.ar(sig, pan, amp);
		Out.ar(out, sig * env);
	}).add;

	0.1.wait;






	win = Window("synth switcher", Rect(0, 0, 800, 300)).front;
	win.background_(Color.grey(0.2));

	win.onClose={
		SystemClock.sched(0.1,{s.freeAll});
	};

	subwin = CompositeView(win, Rect(10, 10, 780, 280))
	.background_(Color.grey(0.4));

	grainView = CompositeView(subwin, Rect(0, 40, 780, 240))
	.background_(Color.grey(0.25));
	grainView.visible_(true);


	playBufView = CompositeView(subwin, Rect(0, 40, 780, 240))
	.background_(Color.grey(0.35));
	playBufView.visible_(false);


	// tgrain controls

	EZSlider(
		grainView, Rect(10, 10, 300, 30),
		"trigger rate",
		ControlSpec(0.1,150,'lin',0.1),
		{|sl|("grain trigger: " ++ sl.value).postln},
		4
	);

	//playbuf controls
	EZSlider(playBufView, Rect(10, 10, 300, 30),
		"playback rate",
		ControlSpec(0.25, 4, 'exp', 0.01),
		{|sl|("playbuf rate: " ++ sl.value).postln},
		1
	);


	// load
	openFile =Button(subwin, Rect(160, 5, 100, 25))
	.states_([["open", Color.black, Color.gray]])
	.action_({
		Dialog.openPanel({|path|
			soundFileA = SoundFile.new;
			soundFileA.openRead(path);
			bufferA = Buffer.readChannel(s, path,channels:[0]);
			("Loaded: " ++path.basename).postln;
		})
	});

	// start button

	startButton = Button(subwin, Rect(270, 5, 80, 25))
	.states_([["START", Color.black, Color.green],["STOP",Color.black,Color.red]])
	.action_({
		|btn|
		if(btn.value ==1){
			if(bufferA.isNil){
				"Load a file first".postln;
				btn.value_(0);
			}{
				if(typeMenu.value == 0){
					currentSynth = Synth(\tGrainsPlayer,[\bufnum, bufferA.bufnum]);
					"Tgrains playing".postln;
				}{
					currentSynth = Synth(\playBuffer, [\bufnum, bufferA.bufnum]);
					"PlayBuffer playing".postln;
				};
			};
		}{
			if(currentSynth.notNil){currentSynth.set(\gate,0); currentSynth = nil};
			"Stopped".postln
		};
	});




	typeMenu = PopUpMenu(subwin, Rect(5, 5, 150, 25))
	.items_(["TGrains", "Playbuf"])
	.action_({|menu|

		switch(menu.value,
			0, {
				grainView.visible_(true);
				playBufView.visible_(false);
			},
			1, {
				grainView.visible_(false);
				playBufView.visible_(true);
			}
		);


		("Selected: " ++menu.item).postln;
	})
})
)