
NetAddr.langPort;
/*
buttons
tunings / scales
re-sampling
wavetable
granular
*/


SynthDef(\extreme_fm, {|out recOut freqBus indexBus att=0.2 rel=0.3 amp=0.25 phaseFreqModBus phaseIndexBus gate=1|
	var freq = In.kr(freqBus, 1);
	var index = In.kr(indexBus, 1);
	var phaseFreqMod = In.kr(phaseFreqModBus, 1);
	var phaseIndex = In.kr(phaseIndexBus, 1);
	var mod = SinOsc.ar(freq, 0, index);
	var sig = SinOsc.ar(freq * mod, SinOsc.kr(phaseFreqMod, 0, phaseIndex) );
	var env = EnvGen.ar(Env.adsr(att, 0.0, 1, rel), gate, doneAction: 2);
	sig = sig * env;
	Out.ar(recOut, sig);
	Out.ar(out, sig!2 ); }).store;

SynthDef(\extreme_recorder, {|in bufnum|
	var sig = In.ar(in, 1);
	RecordBuf.ar(sig, bufnum, loop: 0);
}).store;



28/30

SynthDef(\extreme_player, {|out=0 in bufnum gate=1 rateBus amp=0.5 recTime|
	var rate = In.kr(rateBus, 1);
	var env = EnvGen.ar(Env.adsr(0.4,0.0,1,2.0),gate,doneAction: 2);
	//var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1);
	var sig = BufRd.ar(1, bufnum, Phasor.ar(0, BufRateScale.kr(bufnum) * rate, 0, BufFrames.ir(bufnum) * (recTime /30)), 1, 2);
	Out.ar(out, Pan2.ar(sig*env*amp));
}).store;

~extremeGroup = Group.new;
~recordGroup = Group.after(~extremeGroup);
~playGroup = Group.after(~extremeGroup);

~rateBus = Bus.control(s, 1).set(1);

~recBus = Bus.audio(s, 1);
~recBufs = Array.fill(10,  { Buffer.alloc(s, s.sampleRate * 30); } );


~extremeSwitch = 0;
~extremeBuses = Array.fill(4, { Bus.control(s, 1); });
~extremeBuses[0].set(100);
~extremeBuses[1].set(1);
~extremeBuses[2].set(1);
~extremeBuses[3].set(1);


~bangGates = Array.fill(16, { 0});

~freezeSwitch = nil;


~freqSpec = [50, 600, 4,1].asSpec;
~indexSpec = [1, 500, \linear,0.1].asSpec;
~phaseFreqModSpec = [0.001, 80, \linear,0.1].asSpec;
~phaseIndexSpec = [2, 10000, \exp,10].asSpec;

OSCdef(\btn_0, {|msg, time, addr, recvPort| msg.postln;


	if ( ~freezeSwitch == nil, {

	if ( ~extremeSwitch == 0, {
		if ( msg[1] == 1, {"synth on".postln;
			Synth(\extreme_fm, [\out, 0, \recOut, ~recBus, \freqBus, ~extremeBuses[0].index, \indexBus,~extremeBuses[1].index,
			\phaseFreqModBus, ~extremeBuses[2].index,\phaseIndexBus, ~extremeBuses[3].index ], ~extremeGroup );
			~extremeSwitch = 1; }); }, {
			if (msg[1] == 0, { "synth off".postln;
				~extremeGroup.set(\gate, 0);
				~extremeSwitch = 0;
	}); });

	});

}, '/btn_0', nil);

~playSwitch = nil;
~recSwitch = nil;
~recTime = nil;
~recTimeBus = Bus.control(s, 1).set(0);

~bangGates.put(1,0);
OSCdef(\btn_1, {|msg, time, addr, recvPort|
	//msg.postln;


	if ( ~bangGates[1] == 0, {

			~bangGates.put(1, 1);
		if ( msg[1] == 1, {

			if ( ~playSwitch == nil, {

				"turn on player".postln;
			~playSynth = Synth(\extreme_player, [\in, ~recBus,\rateBus, ~rateBus.index, \recTime, ~recTime,\bufnum, ~recBufs[0] ], ~playGroup);

			~playSwitch = 1;

			}, {
				"turn off player".postln;
				~playGroup.set(\gate,0);
				~playSwitch = nil;

			});
		});


		Task({ 1.do{  0.4.wait; ~bangGates.put(1, 0); }; }).start;
	});


}, '/btn_1', nil);



OSCdef(\btn_2, {|msg, time, addr, recvPort|
	//msg.postln;

		if ( ~bangGates[2] == 0, {

			~bangGates.put(2, 1);
		if ( msg[1] == 1, {

			if ( ~recSwitch == nil, {

			~recSynth = Synth(\extreme_recorder, [\in, ~recBus, \bufnum, ~recBufs[0] ], ~recordGroup);
			~timeTask = Task({ 1.do{ 300.do{|i| var time = i/10; ~recTimeBus.set(time); time.postln; 0.1.wait;};  "end of buffer reached, rec stopped".postln; } }).start;
			~recSwitch = 1;

			}, {
				~recSynth.free;
		~timeTask.stop;
				~recTimeBus.get{|item| ~recTime = item; item.postln; };
				~recSwitch = nil;

			});
		});


		Task({ 1.do{  0.4.wait; ~bangGates.put(2, 0); }; }).start;
	});


}, '/btn_2', nil);


/*  GESTURAL FREEZE BUTTON */
OSCdef(\btn_3, {|msg, time, addr, recvPort|
	//msg.postln; time.postln;

		if ( ~bangGates[3] == 0, { ~bangGates.put(3, 1);
		if ( ~freezeSwitch == nil, { ~freezeSwitch = \on; ~freezeSwitch.postln; },
				{  ~freezeSwitch = nil;
					~freezeSwitch.postln; });
		Task({ 1.do{  0.2.wait; ~bangGates.put(3, 0); }; }).start;
	});

}, '/btn_3', nil);




OSCdef(\btn_4, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_4', nil);

OSCdef(\btn_5, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_5', nil);

OSCdef(\btn_6, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_6', nil);

OSCdef(\btn_7, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_7', nil);

OSCdef(\btn_8, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_8', nil);

OSCdef(\btn_9, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_9', nil);

OSCdef(\btn_10, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_10', nil);

OSCdef(\btn_11, {|msg, time, addr, recvPort| msg.postln;


}, '/btn_11', nil);

OSCdef(\abs_x, {|msg, time, addr, recvPort|
	//msg.postln;


	if ( ~freezeSwitch == nil, {
	~extremeBuses[0].set(~freqSpec.map(msg[1]/1021); );

	});


}, '/abs_x', nil);


OSCdef(\abs_y, {|msg, time, addr, recvPort|
	//msg.postln;

	if ( ~freezeSwitch == nil, {
	~extremeBuses[1].set(~indexSpec.map(msg[1]/1021); );

	});
	}  , '/abs_y', nil);



OSCdef(\abs_rz, {|msg, time, addr, recvPort|
	//msg.postln;

	if ( ~freezeSwitch == nil, {

	~extremeBuses[2].set(~phaseFreqModSpec.map(msg[1]/255); );
	});

	}, '/abs_rz', nil);


OSCdef(\abs_throttle, {|msg, time, addr, recvPort|
	//msg.postln;



	~extremeBuses[3].set(~phaseIndexSpec.map(msg[1]/255); );


	}, '/abs_throttle', nil);














