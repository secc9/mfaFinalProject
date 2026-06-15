// ---- Image class
// tutorial made up from a claude promt in the wish so I can learn to use the class


Image.methodsFor.postln;
Image.new(100,100).respondsTo(\getColor).postln;
Image.new(100,100).respondsTo(\getPixel).postln;
var pixel = img.getPixel(x, y);
(
Dialog.openPanel({ |path|
    var img;
    img = Image.open(path);
    img.postln;        // what does it print?
    img.isValid.postln; // is it actually loaded?
});
)

(
Dialog.openPanel({ |path|
    var img, col;
    img = Image.open(path);
    col = img.getColor(0, 0);
    col.postln;
});
)


(
var img;
Dialog.openPanel({|path|
	img = Image.open(path);
	["width: ", img.width, "height: ", img.height].postln;
	img.plot(freeOnClose: true);
})
)


(
var img, col;
Dialog.openPanel({|path|
	img=Image.open(path);
	col = img.getColor(259, 67);
	("red: " ++ col.red).postln;
	("green: " ++ col.green).postln;
	("blue: " ++ col.blue).postln;
	img.plot;
	// img.free;
})
)


(
s.waitForBoot({
	SynthDef(\sineOsc, {
		arg out=0, freq=440,amp=0.3,gate=1;
		var env, sig;
		env = EnvGen.kr(Env.asr(0.05,1,0.3),gate,doneAction: 2);
		sig = SinOsc.ar(freq) * amp * env;
		Out.ar(out, sig !2);
		}).add;

	0.01.wait;

	Dialog.openPanel({
		|path|
		var img, col, brightness, freq;

		img = Image.open(path);
		col = img.getColor(100, 50);
		brightness = (col.red + col.green + col.blue)/3;
		freq = brightness.linexp(0.001,1,100,4000);
		("brightness: " ++ brightness).postln;
		("freq: " ++ freq).postln;
		Synth(\sineOsc, [\freq, freq]);
		img.free;

	})
})
)


(
s.waitForBoot({
	SynthDef(\sineOsc, {
		|out=0, freq=440, amp=0.3,gate=1|
		var env, sig;
		env= EnvGen.kr(Env.asr(0.1,1,1),gate, doneAction: 2);
		sig = SinOsc.ar(freq, 0, amp) * env;
		Out.ar(out, sig!2);
	}).add;
	0.1.wait;

	{
	Dialog.openPanel({|path|
		var img, syn, scanRow;
		img = Image.open(path);
		scanRow = (img.height /2).asInteger;

		Routine({
			img.width.do{|x|
				var col, brightness, freq;
				col = img.getColor(x, scanRow);
				brightness = (col.red + col.green + col.blue)/3;
				freq = brightness.linexp(0.001,1,80,4000);
				if(syn.notNil){syn.set(\gate, 0)};
				syn = Synth(\sineOsc, [\freq, freq, \amp, brightness * 0.5]);
				0.05.wait;
			};

			img.free;
			"Scan complete".postln;

		}).play;

	});
	}.defer;
})
)


(
s.waitForBoot({
    SynthDef(\sineOsc, {
        |out=0, freq=440, amp=0.3, gate=1|
        var env, sig;
        env = EnvGen.kr(Env.asr(0.1, 1, 1), gate, doneAction: 2);
        sig = SinOsc.ar(freq, 0, amp) * env;
        Out.ar(out, sig ! 2);
    }).add;
    0.1.wait;

    {
        Dialog.openPanel({ |path|
            var img, syn, scanRow, brightnessData;
            img      = Image.open(path);
            scanRow  = (img.height / 2).asInteger;

            // read ALL pixels here, on the AppClock thread
            brightnessData = Array.fill(img.width, { |x|
                var col = img.getColor(x, scanRow);
                (col.red + col.green + col.blue) / 3;
            });

            img.free;  // done with the image now

            // Routine just uses the plain Array -- no Qt calls
            Routine({
                brightnessData.do { |brightness|
                    var freq = brightness.linexp(0.001, 1, 80, 4000);
                    if(syn.notNil) { syn.set(\gate, 0) };
                    syn = Synth(\sineOsc, [\freq, freq, \amp, brightness * 0.5]);
                    0.05.wait;
                };
                "Scan complete".postln;
            }).play;
        });
    }.defer;
})
)


//----------------------------------
// new


({
	Dialog.openPanel({|path|
		var img;
		img = Image.open(path);
		["width: ", img.width, "height: ", img.height].postln;
		img.plot;
	})
}.defer)


(
{
	Dialog.openPanel({|path|
		var img, col;
		img = Image.open(path);
		["width: ", img.width, "height: ", img.height].postln;
		col = img.getColor(0, 0);
		("red: " ++ col.red).postln;
		("green: " ++ col.green).postln;
		("blue: " ++ col.blue).postln;
		img.plot
	})
}.defer
)

(
s.waitForBoot({
	SynthDef(\sineOsc, {
		arg out=0, freq=440, amp=0.4, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate,doneAction: 2);
		sig = SinOsc.ar(freq, phase: 0, mul: amp) * env;
		Out.ar(out, sig!2);
	}).add;

	1.wait;

	{
		Dialog.openPanel({
			|path|
			var img, col, brightness, freq, mousePos;
			mousePos = Window.cursorPosition;
			img = Image.open(path);
			col = img.getColor(mousePos.x.clip(0, img.width-1).asInteger, mousePos.y.clip(0, img.height-1).asInteger);
			brightness = (col.red + col.green + col.blue)/3;
			freq = brightness.linexp(0.001, 1, 100, 4000);
			("brightness: "++brightness).postln;
			("freq: " ++ freq).postln;
			img.free;
			Synth(\sineOsc, [\freq, freq])
		})
	}.defer
})
)



//// step 4

(
s.waitForBoot({
	SynthDef(\sineOsc, {
		arg out=0, freq=440, amp=0.4, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate,doneAction: 2);
		sig = SinOsc.ar(freq, phase: 0, mul: amp) * env;
		Out.ar(out, sig!2);
	}).add;

	1.wait;

	{
		Dialog.openPanel({
			|path|
			var img, scanRow, brightnessData, syn;
			img = Image.open(path);
			scanRow = (img.height/2).asInteger;

			brightnessData = Array.fill(img.width, {|x|
				var col = img.getColor(x, scanRow);
				(col.red+col.green+col.blue)/3;
			});

			img.free;

			Routine({
				brightnessData.do{|brightness|
					var freq = brightness.linexp(0.001, 1, 80,4000);
					if(syn.notNil){syn.set(\gate, 0)};
					syn = Synth(\sineOsc, [\freq, freq, \amp, brightness*0.5]);

					0.05.wait;
				};
				"Scan Complete".postln;
			}).play
		})
	}.defer;
})
)



// step 5
(
s.waitForBoot({
	SynthDef(\sineOsc, {
		arg out=0, freq=440, amp=0.4, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate,doneAction: 2);
		sig = SinOsc.ar(freq, phase: 0, mul: amp) * env;
		Out.ar(out, sig!2);
	}).add;

	1.wait;

{
	Dialog.openPanel({|path|
		var img, pixelArray, x, y, index, col, brightness;
		img = Image.open(path);
		pixelArray = img.pixels;

		x = 10;
		y = 20;
		index = (y * img.width) + x;
		col = Image.pixelToColor(pixelArray[index]);
		brightness = (col.red+col.green+col.blue)/3;
		("brightness at (" ++ x ++ "," ++ y ++ "): " ++ brightness).postln;
		img.free;
	})}.defer;
})



	)


//step 6

(
s.waitForBoot({
		SynthDef(\sineOsc, {
		arg out=0, freq=440, amp=0.4, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate,doneAction: 2);
		sig = SinOsc.ar(freq, phase: 0, mul: amp) * env;
		Out.ar(out, sig!2);
	}).add;

	0.1.wait;


	{
		Dialog.openPanel({|path|
			var img, pixelArray, brightnessRow, freqRow, row = 50;
			img = Image.open(path);
			pixelArray = img.pixels;

			// appclock
			brightnessRow = Array.fill(img.width, {|x|
				var col = Image.pixelToColor(pixelArray[(row*img.width+x)]);
				(col.red+col.green+col.blue)/3;
			});
			freqRow = brightnessRow.collect{|b|
				b.linlin(0, 1, 48, 84).round(1).midicps;
			};
			img.free;

			Pbind(
				\instrument, \sineOsc,
				\freq, Pseq(freqRow, 1),
				\amp, Pseq(brightnessRow.collect{|b| b*0.4+0.1},1),
				\dur, 0.04
			).play
		})
	}.defer

})
)


// step 7

(

s.waitForBoot({
	SynthDef(\sineOsc, {
		arg out=0, freq=440, amp=0.4,pan=0.0, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(1,1,1),gate: gate,doneAction: 2);
		sig = SinOsc.ar(freq, phase: 0, mul: amp) * env;
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	0.1.wait;

	{Dialog.openPanel({|path|
		var img, pixelArray, row=80;
		var redData, greenData, blueData;
		img = Image.open(path);
		pixelArray = img.pixels;

		// extract all three channels
		redData = Array.fill(img.width, {|x| Image.pixelToColor(pixelArray[(row*img.width)+x]).red});
		greenData = Array.fill(img.width, {|x| Image.pixelToColor(pixelArray[(row*img.width)+x]).green});
		blueData = Array.fill(img.width, {|x| Image.pixelToColor(pixelArray[(row*img.width)+x]).blue});

		img.free;

		Pbind(
			\instrument, \sineOsc,
			\freq, Pseq(redData.collect{|v|v.linexp(0.001,1,100,3000)},1),
			\amp, Pseq(greenData.collect{|v|v.linlin(0,1,0.05,0.5)},1),
			\pan, Pseq(blueData.collect{|v|v.linlin(0,1,-1,1)},1),
			\dur,0.04
		).play;
	})}.defer;
})
)


s.meter



(
{
	Dialog.openPanel({|path|
		var img, win;
		img = Image.open(path);
		win = Window("imageViewer", Rect(0, 0, 420, 320)).front;
		win.background_(Color.black);
		win.onClose_({img.free});
		win.drawHook_({
			img.drawInRect(Rect(10, 10, 400, 300));
		});
		win.refresh;
	})
}.defer
)




























